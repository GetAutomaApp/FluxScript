import Foundation

public enum TokenizerError: Error {
    case invalidCharacter
    case unterminatedString
    case invalidEscapeCharacter
}

public enum TokenType {
    case string
}

public struct Token {
    public let literal: String
    public let type: TokenType
    public let lineStart: Int
    public let lineEnd: Int
    public let start: Int
    public let end: Int
}

public class Tokenizer {
    let source: String
    var tokens: [Token] = []
    var current: Int = 0
    var start:  Int = 0
    var line: Int = 1
    
    public init(source: String) {
        self.source = source
    }
    
    public func scanTokens() throws -> [Token] {
        current = 0
        while !isAtEnd() {
            start = current
            try scanToken()
        }
        
        return tokens
    }
    
    func scanToken() throws {
        let literal = advance()
        
        switch literal {
            case "\n":
                line += 1
            case "\"":
                try string()
            default:
                throw TokenizerError.invalidCharacter
        }
    }
    
    @discardableResult
    func advance() -> Character {
        if isAtEnd() {
            return "\0"
        }
        
        let index = source.index(source.startIndex, offsetBy: current)
        
        current += 1
        
        return source[index]
    }
    
    func peek() -> Character {
        if isAtEnd() {
            return "\0"
        }
        
        let index = source.index(source.startIndex, offsetBy: current)
        return source[index]
    }
    
    func isAtEnd() -> Bool {
        return current >= source.count
    }
    
    func addToken(type tokenType: TokenType, literal: String, startLine: Int) {
        let token = Token(
            literal: literal,
            type: tokenType,
            lineStart: startLine,
            lineEnd: line,
            start: start,
            end: current
        )
        tokens.append(token)
    }
    
    func string() throws {
        var literal: String = ""
        var isQuoted: Bool = false
        let startLine: Int = line
        
        while !isAtEnd() {
            let character = advance()
            // This adds support for multiline strings
            if character == "\n" {
                let isBeforeQuoted = peek() == "\""
                if !literal.isEmpty && !isBeforeQuoted {
                    literal += "\n"
                }
                
                line += 1
                continue
            }
            
            // This allows us to add support for escaping characters as well!
            if character == "\\" {
                let nextCharacter = peek()
                if nextCharacter == "n" {
                    advance()
                    literal += "\n"
                } else if nextCharacter == "t" {
                    advance()
                    literal += "\t"
                } else if nextCharacter == "\\" {
                    advance()
                    literal += "\\"
                } else if nextCharacter == "\"" {
                   advance()
                    literal += "\""
                } else {
                    throw TokenizerError.invalidEscapeCharacter
                }
                continue
            }
            
            if character != "\"" {
                literal = "\(literal)\(character)"
            } else {
                isQuoted.toggle()
                break
            }
        }
        
        if isQuoted {
            addToken(
                type: .string,
                literal: literal,
                startLine: startLine
            )
        } else {
            throw TokenizerError.unterminatedString
        }
    }
}
