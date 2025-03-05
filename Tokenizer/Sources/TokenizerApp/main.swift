import Tokenizer

let source = """
"this is a test"
"string 2"
"Bob Said: \\"Hi, How are you?\\""
"
Bob Said:
\\"What are you doing?\\"
"
"""

let source2 = """
123
123.4
"""

let source3 = """
+ - * / ** % ^
"""

let source4 = """
funkydoodle
var
2 * a * 1.1 + 9^10
"""

let fullSource = "\(source)\n\(source2)\n\(source3)\n\(source4)"

let tokenizer = Tokenizer(source: source4)
print(try tokenizer.scanTokens())
