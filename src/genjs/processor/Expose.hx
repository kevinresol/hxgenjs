package genjs.processor;

enum Expose {
	EClassField(c:ProcessedClass, f:ProcessedField);
	EClass(c:ProcessedClass);
}