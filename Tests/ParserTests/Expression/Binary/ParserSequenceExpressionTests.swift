/*
   Copyright 2017 Ryuichi Intellectual Property and the Yanagiba project contributors

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

import XCTest

@testable import AST

class ParserSequenceExpressionTests: XCTestCase {
  func testBinaryOperators() { // swift-lint:suppress(high_cyclomatic_complexity)
    let testOps = [
      // regular operators
      "/",
      "-",
      "+",
      "--",
      "++",
      "+=",
      "=-",
      "==",
      "!*",
      "*<",
      "<>",
      "<!>",
      ">?>?>",
      "&|^~?",
      ">>>!!>>",
      "??",
      // dot operators
      "..",
      "...",
      ".......................",
      "../",
      "...++",
      "..--"
    ]

    for testOp in testOps {
      for space in ["", " ", "     "] {
        let testCode = "fo\(space)\(testOp)\(space)ob\(space)\(testOp)\(space)ar"
        let expectedCode = "fo \(testOp) ob \(testOp) ar"

        parseExpressionAndTest(testCode, expectedCode, testClosure: { expr in
          guard let seqExpr = expr as? SequenceExpression else {
            XCTFail("Failed in getting a sequence expression for code `testCode`")
            return
          }
          let elements = seqExpr.elements
          guard case .expression(let ele0) = elements[0], ele0 is IdentifierExpression,
            case .binaryOperator(let ele1) = elements[1], ele1 == testOp,
            case .expression(let ele2) = elements[2], ele2 is IdentifierExpression,
            case .binaryOperator(let ele3) = elements[3], ele3 == testOp,
            case .expression(let ele4) = elements[4], ele4 is IdentifierExpression
          else {
            XCTFail("Failed in getting a sequence element")
            return
          }
          XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, 1+testCode.count))
        })
      }
    }

    for testOp in testOps {
      for space in ["", " ", "     "] {
        let testCode = "a\(space)\(testOp)\(space)b\(space)\(testOp)\(space)c\(space)\(testOp)\(space)d"
        let expectedCode = "a \(testOp) b \(testOp) c \(testOp) d"

        parseExpressionAndTest(testCode, expectedCode, testClosure: { expr in
          guard let seqExpr = expr as? SequenceExpression else {
            XCTFail("Failed in getting a sequence expression for code `testCode`")
            return
          }
          let elements = seqExpr.elements
          guard case .expression(let ele0) = elements[0], ele0 is IdentifierExpression,
            case .binaryOperator(let ele1) = elements[1], ele1 == testOp,
            case .expression(let ele2) = elements[2], ele2 is IdentifierExpression,
            case .binaryOperator(let ele3) = elements[3], ele3 == testOp,
            case .expression(let ele4) = elements[4], ele4 is IdentifierExpression,
            case .binaryOperator(let ele5) = elements[5], ele5 == testOp,
            case .expression(let ele6) = elements[6], ele6 is IdentifierExpression
          else {
            XCTFail("Failed in getting a sequence element")
            return
          }
          XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, 1+testCode.count))
        })
      }
    }
  }

  func testAssignmentOperators() { // swift-lint:suppress(high_cyclomatic_complexity)
    parseExpressionAndTest("foo = bar = true", "foo = bar = true", testClosure: { expr in
      guard let seqExpr = expr as? SequenceExpression else {
        XCTFail("Failed in getting a sequence expression")
        return
      }
      let elements = seqExpr.elements
      guard case .expression(let ele0) = elements[0], ele0 is IdentifierExpression,
        case .assignmentOperator = elements[1],
        case .expression(let ele2) = elements[2], ele2 is IdentifierExpression,
        case .assignmentOperator = elements[3],
        case .expression(let ele4) = elements[4], ele4 is LiteralExpression
      else {
        XCTFail("Failed in getting a sequence element")
        return
      }
      XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, 17))
    })

    parseExpressionAndTest(
      "a = try b()  = true   = try! c()",
      "a = try b() = true = try! c()",
      testClosure: { expr in
      guard let seqExpr = expr as? SequenceExpression else {
        XCTFail("Failed in getting a sequence expression")
        return
      }
      let elements = seqExpr.elements
      guard case .expression(let ele0) = elements[0], ele0 is IdentifierExpression,
        case .assignmentOperator = elements[1],
        case .expression(let ele2) = elements[2], ele2 is TryOperatorExpression,
        case .assignmentOperator = elements[3],
        case .expression(let ele4) = elements[4], ele4 is LiteralExpression,
        case .assignmentOperator = elements[5],
        case .expression(let ele6) = elements[6], ele6 is TryOperatorExpression
      else {
        XCTFail("Failed in getting a sequence element")
        return
      }
      XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, 33))
    })
  }

  func testTernaryConditionalOperators() {
     // (a ? b : c) ? (d ? e : f) : g
    parseExpressionAndTest(
      "a ? b : c ? d ? e : f : g",
      "a ? b : c ? d ? e : f : g",
      testClosure: { expr in
        guard let sequenceExpr = expr as? SequenceExpression else {
          XCTFail("Failed in getting a sequence expr for code `a ? b : c ? d ? e : f : g`.")
          return
        }

        let elements = sequenceExpr.elements
        guard case .expression(let ele0) = elements[0], ele0 is IdentifierExpression,
          case .ternaryConditionalOperator(let ele1) = elements[1], ele1 is IdentifierExpression,
          case .expression(let ele2) = elements[2], ele2 is IdentifierExpression,
          case .ternaryConditionalOperator(let ele3) = elements[3], ele3 is TernaryConditionalOperatorExpression,
          case .expression(let ele4) = elements[4], ele4 is IdentifierExpression
        else {
          XCTFail("Failed in getting a sequence element")
          return
        }
        XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, 26))
      }
    )
  }

  func testTypeCastingOperators() { // swift-lint:suppress(nested_code_block_depth)
    let castings = ["is", "as", "as?", "as!"]
    for c1 in castings {
      for c2 in castings {
        let testCode = "foobar \(c1) Foo \(c2) Bar"
        parseExpressionAndTest(testCode, testCode, testClosure: { expr in
          guard let sequenceExpr = expr as? SequenceExpression else {
            XCTFail("Failed in getting a sequence expr for code `\(testCode)`.")
            return
          }

          let elements = sequenceExpr.elements
          guard case .expression(let ele0) = elements[0], ele0 is IdentifierExpression else {
            XCTFail("Failed in getting a sequence element")
            return
          }

          switch (c1, elements[1]) {
          case ("is", .typeCheck), ("as", .typeCast), ("as?", .typeConditionalCast), ("as!", .typeForcedCast):
            break
          default:
            XCTFail("Failed in getting a type casting")
          }

          switch (c2, elements[2]) {
          case ("is", .typeCheck), ("as", .typeCast), ("as?", .typeConditionalCast), ("as!", .typeForcedCast):
            break
          default:
            XCTFail("Failed in getting a type casting")
          }

          XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, 1 + testCode.count))
        })
      }
    }
  }

  func testCombinations() {
    let combinations = [
      "a && b || c",
      // "a && b = c",
      "a && b ? c : d",
      "a && b is c",
      "a && b as c",
      "a && b as? c",
      "a && b as! c",
      "a = b || c",
      "a = b = c",
      "a = b ? c : d",
      "a = b is c",
      "a = b as c",
      "a = b as? c",
      "a = b as! c",
      "x ? y : z || c",
      "x ? y : z = c",
      "x ? y : z ? c : d",
      "x ? y : z is c",
      "x ? y : z as c",
      "x ? y : z as? c",
      "x ? y : z as! c",
      "a is b || c",
      "a is b = c",
      "a is b ? c : d",
      "a is b is c",
      "a is b as c",
      "a is b as? c",
      "a is b as! c",
      "a as b || c",
      "a as b = c",
      "a as b ? c : d",
      "a as b is c",
      "a as b as c",
      "a as b as? c",
      "a as b as! c",
      "a as? b || c",
      "a as? b = c",
      "a as? b ? c : d",
      "a as? b is c",
      "a as? b as c",
      "a as? b as? c",
      "a as? b as! c",
      "a as! b || c",
      "a as! b = c",
      "a as! b ? c : d",
      "a as! b is c",
      "a as! b as c",
      "a as! b as? c",
      "a as! b as! c",
    ]
    for c in combinations {
      parseExpressionAndTest(c, c, testClosure: { expr in
        XCTAssertTrue(expr is SequenceExpression)
      })
    }
  }

  static var allTests = [
    ("testBinaryOperators", testBinaryOperators),
    ("testAssignmentOperators", testAssignmentOperators),
    ("testTernaryConditionalOperators", testTernaryConditionalOperators),
    ("testTypeCastingOperators", testTypeCastingOperators),
    ("testCombinations", testCombinations),
  ]
}
