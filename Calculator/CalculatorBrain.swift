//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Fedor Borodin on 20/07/2017.
//  Copyright © 2017 Fedor Borodin. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    
    // MARK: - Properties
    
    private var accumulator: (Double?, String?)
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        formatter.notANumberSymbol = "N/A"
        formatter.groupingSeparator = " "
        formatter.locale = Locale.current
        return formatter
    }()
    
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
    
    var description: String? {
        get {
            if pendingBinaryOperation == nil {
                return accumulator.1
            } else {
                return pendingBinaryOperation!.descFunction(pendingBinaryOperation!.descOperand, accumulator.1 ?? "")
            }
        }
    }
    
    var result: Double? {
        get {
            return accumulator.0
        }
    }
    
    private enum Operation {
        case randomNumberGeneration(() -> Double, String)
        case constant(Double)
        case unaryOperation((Double) -> Double, ((String) -> String)?)
        case binaryOperation((Double, Double) -> Double, ((String, String) -> String)?)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "Ran" : Operation.randomNumberGeneration({Double(arc4random())/Double(UInt32.max)}, "rand()"),
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt, nil),          // {"√(\($0))"}
        "sin" : Operation.unaryOperation(sin, nil),
        "cos" : Operation.unaryOperation(cos, nil),
        "tan" : Operation.unaryOperation(tan, nil),
        "ln" : Operation.unaryOperation(log, nil),
        "x²" : Operation.unaryOperation({ $0 * $0 }, { "(\($0))²" }),
        "±" : Operation.unaryOperation({ -$0 }, nil),
        "×" : Operation.binaryOperation(*, nil),            // {"\($0) * \($1)"}
        "÷" : Operation.binaryOperation(/, nil),
        "+" : Operation.binaryOperation(+, nil),
        "−" : Operation.binaryOperation(-, nil),
        "=" : Operation.equals
    ]
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        var descFunction: (String, String) -> String
        var descOperand: String
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
        
        func descPerform(with secondOperand: String) -> String {
            return descFunction(descOperand, secondOperand)
        }
    }
    
    
    // MARK: - Methods
    
    mutating func setOperand(_ operand: Double) {
        accumulator.0 = operand
        accumulator.1 = formatter.string(from: NSNumber(value:operand)) ?? ""
    }

    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            
            switch operation {
            
            case .randomNumberGeneration(let function):
                accumulator = (function.0(), function.1)
            
            case .constant(let value):
                accumulator = (value, symbol)
            
            case .unaryOperation(let function, var desc):
                if accumulator.0 != nil {
                    accumulator.0 = function(accumulator.0!)
                    if desc == nil {
                        desc = { symbol + "(" + $0 + ")" }
                    }
                    accumulator.1 = desc!(accumulator.1!)
                }
            
            case .binaryOperation(let function, var desc):
                performPendingBinaryOperation()
                if accumulator.0 != nil {
                    if desc == nil {
                        desc = { $0 + " " + symbol + " " + $1 }
                    }
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator.0!, descFunction: desc!, descOperand: accumulator.1!)
                    accumulator = (nil, nil)
                }
            
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator.0 != nil {
            accumulator.0 = pendingBinaryOperation!.perform(with: accumulator.0!)
            accumulator.1 = pendingBinaryOperation!.descPerform(with: accumulator.1!)
            pendingBinaryOperation = nil
        }
    }
    
    mutating func reset() {
        accumulator = (nil, nil)
        pendingBinaryOperation = nil
    }
}
