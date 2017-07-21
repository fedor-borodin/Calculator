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
    
    var resultIsPending: Bool {
        get {
            return (pendingBinaryOperation != nil)
        }
    }
    
    var description: String {
        get {
            if let desc = accumulator.1 {
                return desc
            } else {
                return " "
            }
        }
    }
    
    var result: Double? {
        get {
            return accumulator.0
        }
    }
    
    private enum Operation {
        case constant((Double, String))
        case unaryOperation(((Double) -> Double, (String) -> String))
        case binaryOperation(((Double, Double) -> Double, String))
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant((Double.pi, "π")),
        "e" : Operation.constant((M_E, "e")),
        "√" : Operation.unaryOperation((sqrt, {"√(\($0))"})),
        "sin" : Operation.unaryOperation((sin, {"sin(\($0))"})),
        "cos" : Operation.unaryOperation((cos, {"cos(\($0))"})),
        "tan" : Operation.unaryOperation((tan, {"tan(\($0))"})),
        "ln" : Operation.unaryOperation((log, {"ln(\($0))"})),
        "x²" : Operation.unaryOperation(({$0 * $0}, {"(\($0))²"})),
        "±" : Operation.unaryOperation(({ -$0 }, {"-(\($0))"})),
        "×" : Operation.binaryOperation(({$0 * $1}, "*")),
        "÷" : Operation.binaryOperation(({$0 * $1}, "÷")),
        "+" : Operation.binaryOperation(({$0 + $1}, "+")),
        "−" : Operation.binaryOperation(({$0 - $1}, "-")),
        "=" : Operation.equals
    ]
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    
    // MARK: - Methods
    
    mutating func setOperand(_ operand: Double) {
        accumulator.0 = operand
        accumulator.1 = (accumulator.1 ?? "") + " " + String(operand)
    }

    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator.0 = value.0
                accumulator.1 = (pendingBinaryOperation != nil) ? accumulator.1! + " " + value.1 : value.1
            case .unaryOperation(let function):
                if accumulator.0 != nil {
                    accumulator.1 = (pendingBinaryOperation != nil) ? accumulator.1! + " " + function.1(String(accumulator.0!)) : function.1(accumulator.1!)
                    accumulator.0 = function.0(accumulator.0!)
                }
            case .binaryOperation(let function):
                if accumulator.0 != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function.0, firstOperand: accumulator.0!)
                    accumulator.1 = accumulator.1! + " " + function.1
                    accumulator.0 = nil
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator.0 != nil {
            accumulator.0 = pendingBinaryOperation!.perform(with: accumulator.0!)
            pendingBinaryOperation = nil
        }
    }
}
