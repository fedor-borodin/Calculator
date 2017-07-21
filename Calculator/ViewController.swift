//
//  ViewController.swift
//  Calculator
//
//  Created by Fedor Borodin on 20/07/2017.
//  Copyright © 2017 Fedor Borodin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    // MARK: - Properties
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    var userTypedDecimalPoint = false
    
    private var brain = CalculatorBrain()
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    
    // MARK: - Actions
    
    // A user touched a digit
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit == "." ? "0." : digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    // A user touched a decimal point
    @IBAction func touchDecimalPoint(_ sender: UIButton) {
        if !userTypedDecimalPoint {
            userTypedDecimalPoint = true
            touchDigit(sender)
        }
    }
    
    // A user touched an operation button
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
            userTypedDecimalPoint = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
            historyLabel.text = brain.resultIsPending ? brain.description + " ..." : brain.description + " ="
        }
        if let result = brain.result {
            displayValue = result
        }
    }
    
}

