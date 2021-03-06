#!/usr/bin/env dart
// Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
// This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
// The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
// The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
// Code distributed by Google as part of the polymer project is also
// subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

import 'dart:io';
import 'package:path/path.dart' as path;
import 'src/ast.dart';
import 'src/codegen.dart';
import 'src/config.dart';
export 'src/config.dart' show GlobalConfig;
import 'src/parser.dart';

bool verbose = false;

GlobalConfig parseArgs(args, String program) {
  if (args.length == 0) {
    print('usage: call this tool with either input files '
        'or a configuration file that describes input files and name '
        'substitutions. For example: ');
    print('    $program lib/src/x-a/x-a.html lib/src/x-b/x-c.html ...');
    print('    $program config.yaml');
    print('    $program config.yaml lib/src/x-a/x-a.html config2.yaml');
    exit(1);
  }

  var config = new GlobalConfig();
  for (var arg in args) {
    if (arg.endsWith('.html')) {
      config.files[arg] = new FileConfig(config);
    } else if (arg.endsWith('.yaml')) {
      _progress('Parsing configuration ... ');
      parseConfigFile(arg, config);
    }
  }

  return config;
}

void generateWrappers(GlobalConfig config) {
  _progress('Parsing files... ');
  var fileSummaries = [];
  var elementSummaries = {};
  var mixinSummaries = {};
  var len = config.files.length;
  int i = 0;
  config.files.forEach((inputPath, fileConfig) {
    _progress('${++i} of $len: $inputPath');
    var summary = _parseFile(inputPath);
    fileSummaries.add(summary);
    for (var elementSummary in summary.elements) {
      var name = elementSummary.name;
      if (elementSummaries.containsKey(name)) {
        print('Error: found two elements with the same name ${name}');
        exit(1);
      }
      elementSummaries[name] = elementSummary;
    }
    for (var mixinSummary in summary.mixins) {
      var name = mixinSummary.name;
      if (mixinSummaries.containsKey(name)) {
        print('Error: found two mixins with the same name ${name}');
        exit(1);
      }
      mixinSummaries[name] = mixinSummary;
    }
  });

  _progress('Running codegen... ');
  len = config.files.length;
  i = 0;
  config.files.forEach((inputPath, fileConfig) {
    var fileSummary = fileSummaries[i];
    _progress('${++i} of $len: $inputPath');
    _generateDartApi(
        fileSummary, elementSummaries, mixinSummaries, inputPath, fileConfig);
  });


  // We assume that the file has to be there because of bower, even though we
  // could generate without.
  _progress('Checking original files exist for stubs');
  for (var inputPath in config.stubs.keys) {
    var file = new File(inputPath);
    if (!file.existsSync()) {
      print("error: stub file $inputPath doesn't exist");
      exit(1);
    }
  }

  _progress('Deleting files... ');
  _deleteFilesMatchingPatterns(config.deletionPatterns);

  _progress('Generating stubs... ');
  len = config.stubs.length;
  i = 0;
  config.stubs.forEach((inputPath, packageName) {
    _progress('${++i} of $len: $inputPath');
    _generateImportStub(inputPath, packageName);
  });

  _progress('Done');
  stdout.write('\n');
}

void _generateImportStub(String inputPath, String packageName) {
  var file = new File(inputPath);
  // File may have been deleted, make sure it still exists.
  file.createSync(recursive: true);

  var segments = path.split(inputPath);
  var newFileName = segments.last.replaceAll('-', '_');
  var depth = segments.length;
  var goingUp = '../' * depth;
  var newPath = path.join(goingUp, 'packages/$packageName', newFileName);
  file.writeAsStringSync(
      '<link rel="import" href="$newPath">\n'
      '$EMPTY_SCRIPT_WORKAROUND_ISSUE_11');
}

/// Reads the contents of [inputPath], parses the documentation, and then
/// generates a FileSummary for it.
FileSummary _parseFile(String inputPath, {bool ignoreFileErrors: false}) {
  _progressLineBroken = false;
  if (!new File(inputPath).existsSync()) {
    if (ignoreFileErrors) {
      return new FileSummary();
    } else {
      print("error: file $inputPath doesn't exist");
      exit(1);
    }
  }
  var isHtml = inputPath.endsWith('.html');
  var text = new File(inputPath).readAsStringSync();
  var summary = new PolymerParser(
      text, isHtml: isHtml, onWarning: (s) => _showMessage('warning: $s'))
      .parse();

  if (summary.elements.isEmpty && summary.mixins.isEmpty && isHtml) {
    // If we didn't find any elements, try to find a corresponding *.js file
    var jsPath = inputPath.replaceFirst('.html', '.js');
    var jsSummary = _parseFile(jsPath, ignoreFileErrors: true);
    summary.elementsMap = jsSummary.elementsMap;
    summary.mixinsMap = jsSummary.mixinsMap;
  }
  _showMessage('$summary');
  return summary;
}

/// Takes a FileSummary, and generates a Dart API for it. The input code must be
/// under lib/src/ (for example, lib/src/x-tag/x-tag.html), the output will be
/// generated under lib/ (for example, lib/x_tag/x_tag.dart).
void _generateDartApi(
      FileSummary summary, Map<String, Element> elementSummaries,
      Map<String, Mixin> mixinSummaries, String inputPath, FileConfig config) {
  _progressLineBroken = false;
  var segments = path.split(inputPath);
  if (segments.length < 4 || segments[0] != 'lib' || segments[1] != 'src'
      || !segments.last.endsWith('.html')) {
    print('error: expected $inputPath to be of the form '
          'lib/src/x-tag/**/x-tag2.html');
    exit(1);
  }

  var dashName = path.joinAll(segments.getRange(2, segments.length));
  var name = path.withoutExtension(segments.last).replaceAll('-', '_');
  var isSubdir = segments.length > 4;
  var outputDirSegments = ['lib'];
  if (isSubdir) {
    outputDirSegments.addAll(segments.getRange(2, segments.length - 1)
        .map((s) => s.replaceAll('-', '_')));
  }
  var outputDir = path.joinAll(outputDirSegments);

  // Only create a dart file if we found at least one polymer element.
  var hasDartFile = summary.elements.isNotEmpty || summary.mixins.isNotEmpty;
  if (hasDartFile) {
    var dartContent = new StringBuffer();
    dartContent.write(generateDirectives(name, summary, config));
    var first = true;
    for (var element in summary.elements) {
      if (!first) dartContent.write('\n\n');
      dartContent.write(generateClass(element, config, elementSummaries));
      first = false;
    }
    for (var mixin in summary.mixins) {
      if (!first) dartContent.write('\n\n');
      dartContent.write(generateClass(mixin, config, mixinSummaries));
      first = false;
    }
    new File(path.join(outputDir, '$name.dart'))
        ..createSync(recursive: true)
        ..writeAsStringSync(dartContent.toString());
  }

  var extraImports = new StringBuffer();
  var packageLibDir = (isSubdir) ? '../' * (segments.length - 3) : '';
  for (var jsImport in summary.imports) {
    var importPath = jsImport.importPath;
    if (importPath.contains('polymer.html')) continue;
    var omit = config.omitImports;
    if (omit != null && omit.any((path) => importPath.contains(path))) {
      continue;
    }
    var importSegments = path.split(importPath);
    if (importSegments[0] == '..') {
      importSegments.removeRange(0, segments.length - 2);
    }
    var dartImport = path.joinAll(importSegments).replaceAll('-', '_');
    var targetElement = importSegments.last;
    var packageName = config.global.findPackageNameForElement(targetElement);
    if (packageName != null) {
      dartImport = path.join(
          '..', '..', packageLibDir, 'packages', packageName, dartImport);
    } else {
      dartImport = path.join(packageLibDir, dartImport);
    }
    extraImports.write('<link rel="import" href="$dartImport">\n');
  }

  var htmlBody =
      '<link rel="import" href="${packageLibDir}src/$dashName">\n$extraImports';
  var scriptTag = '';
  if (hasDartFile) {
    scriptTag = '<script type="application/dart" src="$name.dart"></script>\n';
  }
  new File(path.join(outputDir, '$name.html'))
      ..createSync(recursive: true)
      ..writeAsStringSync('$htmlBody$scriptTag');
}

void _deleteFilesMatchingPatterns(List<RegExp> patterns) {
  new Directory('lib/src')
      .listSync(recursive: true, followLinks: false)
      .where((file) => patterns.any((pattern) =>
          path.relative(file.path, from: 'lib/src').contains(pattern)))
      .forEach((file) {
        if (file.existsSync()) file.deleteSync(recursive: true);
      });
}

int _lastLength = 0;
_progress(String msg) {
  const ESC = '\x1b';
  stdout.write('\r$ESC[32m$msg$ESC[0m');
  var len = msg.length;
  if (len < _lastLength && !verbose) {
    stdout.write(' ' * (_lastLength - len));
  }
  _lastLength = len;
}

bool _progressLineBroken = false;
_showMessage(String msg) {
  if (!verbose) return;
  if (!_progressLineBroken) {
    _progressLineBroken = true;
    stdout.write('\n');
  }
  print(msg);
}

const String EMPTY_SCRIPT_WORKAROUND_ISSUE_11 = '''
<script>
// This empty script is here to workaround issue
// https://github.com/dart-lang/core-elements/issues/11
</script>''';
