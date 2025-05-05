import Testing
@testable import Tokenizer

@Suite("Tokenizer Tests")
struct TokenizerTests {
    @Test(
        arguments: [
            (
                "\"Hello, There!\"",
                [
                    Token(literal: "Hello, There!", type: .string, lineStart: 1, lineEnd: 1, start: 0, end: 15),
                ]
            ),
            (
                "\"Hello, \\\"World\\\"!\"",
                [
                    Token(literal: "Hello, \"World\"!", type: .string, lineStart: 1, lineEnd: 1, start: 0, end: 19),
                ]
            ),
            (
                "\"Line1\\nLine2\"",
                [
                    Token(literal: "Line1\nLine2", type: .string, lineStart: 1, lineEnd: 1, start: 0, end: 14),
                ]
            ),
            (
                "\"Line1\nLine2\"",
                [
                    Token(literal: "Line1\nLine2", type: .string, lineStart: 1, lineEnd: 2, start: 0, end: 13),
                ]
            ),
            (
                "+ - * / % ^ **",
                [
                    Token(literal: "+", type: .addition, lineStart: 1, lineEnd: 1, start: 0, end: 1),
                    Token(literal: "-", type: .subtraction, lineStart: 1, lineEnd: 1, start: 2, end: 3),
                    Token(literal: "*", type: .multiplication, lineStart: 1, lineEnd: 1, start: 4, end: 5),
                    Token(literal: "/", type: .division, lineStart: 1, lineEnd: 1, start: 6, end: 7),
                    Token(literal: "%", type: .modulus, lineStart: 1, lineEnd: 1, start: 8, end: 9),
                    Token(literal: "^", type: .exponentiation, lineStart: 1, lineEnd: 1, start: 10, end: 11),
                    Token(literal: "**", type: .power, lineStart: 1, lineEnd: 1, start: 12, end: 14),
                ]
            ),
            (
                "123",
                [
                    Token(literal: "123", type: .number, lineStart: 1, lineEnd: 1, start: 0, end: 3),
                ]
            ),
            (
                "3.14",
                [
                    Token(literal: "3.14", type: .number, lineStart: 1, lineEnd: 1, start: 0, end: 4),
                ]
            ),
            (
                """
                "this is a test"
                "string 2"
                "Bob Said: \\"Hi, How are you?\\""
                "
                Bob Said:
                \\"What are you doing?\\"
                "
                """,
                [
                    Token(literal: "this is a test", type: .string, lineStart: 1, lineEnd: 1, start: 0, end: 16),
                    Token(literal: "string 2", type: .string, lineStart: 2, lineEnd: 2, start: 17, end: 27),
                    Token(literal: "Bob Said: \"Hi, How are you?\"", type: .string, lineStart: 3, lineEnd: 3, start: 28, end: 60),
                    Token(literal: "Bob Said:\n\"What are you doing?\"", type: .string, lineStart: 4, lineEnd: 7, start: 61, end: 98)
                ]
            ),
            (
                """
                funkydoodle
                var
                """,
                [
                    Token(literal: "funkydoodle", type: .identifier, lineStart: 1, lineEnd: 1, start: 0, end: 11),
                    Token(literal: "var", type: .variable, lineStart: 2, lineEnd: 2, start: 12, end: 15)
                ]
            ),
            (
                "\"\"",
                [Token(literal: "", type: .string, lineStart: 1, lineEnd: 1, start: 0, end: 2)]
            ),
            (
                "\"C:\\\\Path\\\\to\\\\file\"",
                [Token(literal: "C:\\Path\\to\\file", type: .string, lineStart: 1, lineEnd: 1, start: 0, end: 20)]
            ),
            (
                "* *",
                [
                    Token(literal: "*", type: .multiplication, lineStart: 1, lineEnd: 1, start: 0, end: 1),
                    Token(literal: "*", type: .multiplication, lineStart: 1, lineEnd: 1, start: 2, end: 3)
                ]
            ),
            (
                """
                123

                456
                """,
                [
                    Token(literal: "123", type: .number, lineStart: 1, lineEnd: 1, start: 0, end: 3),
                    Token(literal: "456", type: .number, lineStart: 3, lineEnd: 3, start: 5, end: 8)
                ]
            ),
            (
                "var123",
                [Token(literal: "var123", type: .identifier, lineStart: 1, lineEnd: 1, start: 0, end: 6)]
            ),
            (
                "-5",
                [
                    Token(literal: "-", type: .subtraction, lineStart: 1, lineEnd: 1, start: 0, end: 1),
                    Token(literal: "5", type: .number, lineStart: 1, lineEnd: 1, start: 1, end: 2)
                ]
            ),
            (
                "***",
                [
                    Token(literal: "**", type: .power, lineStart: 1, lineEnd: 1, start: 0, end: 2),
                    Token(literal: "*", type: .multiplication, lineStart: 1, lineEnd: 1, start: 2, end: 3)
                ]
            ),
            (
                "^ ^",
                [
                    Token(literal: "^", type: .exponentiation, lineStart: 1, lineEnd: 1, start: 0, end: 1),
                    Token(literal: "^", type: .exponentiation, lineStart: 1, lineEnd: 1, start: 2, end: 3)
                ]
            )
        ]
    ) func parseStrings(input: String, expectedOutputs: [Token]) throws {
        let tokenizer = Tokenizer(source: input)
        let tokens = try tokenizer.scanTokens()
        #expect(tokens == expectedOutputs)
    }

    @Test(
        arguments: [
            ("\"unterminated", TokenizerError.unterminatedString),
            ("\"Bad escape: \\q\"", TokenizerError.invalidEscapeCharacter),
            ("3.1.4", TokenizerError.invalidNumber),
            ("$", TokenizerError.invalidCharacter),
        ]
    )
    func errorCases(input: String, error: TokenizerError) throws {
        let tokenizer = Tokenizer(source: input)
        #expect(throws: error) {
            try tokenizer.scanTokens()
        }
    }
}
