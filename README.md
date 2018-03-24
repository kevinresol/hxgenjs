# hxgenjs

Extensible JS generator for Haxe

The default configuration emits one javascript file per Haxe class, and uses CommonJS (`require()`) to link the dependencies.
It should work out of the box with your current Node.js project, React Native project or any other CommonJS-compatible runtimes.
For browsers usage you can use packagers such as Webpack or Browserify, etc.

Note: This is written for Haxe version >= 3.4, it may not be usable on earlier versions.

# Usage

Simply install the library and add `-lib hxgenjs` to your project.

Options:

- add `-D js_es=6` if you want to generate ES6 classes.
- add `-D hxextern` if you want to generate Haxe extern files.
- add `-D tsextern` if you want to generate TypeScript definition files.
- add `-D genjs=no` if you don't want to generate Javascript files.

# Custom Generators

1. Implements the interfaces in the genjs.generator package (`IClassGenerator`, `IEnumGenerator`, `IMainGenerator`)
2. Configure hxgenjs:

```haxe
class Setup {
	public static function setup() {
		var customConfig:genjs.Generator.Config = ...;
		genjs.Generator.generators.push(customConfig);
	}
}
```

Then run it as init macro in your build:
`--macro Setup.setup()`


## Work in progress

- [x] Generate javascript file per Haxe class
- [x] Handle @:expose
- [x] Standardize way to configure the generator
