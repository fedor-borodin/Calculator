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
            display.text = brain.formatter.string(from: NSNumber(value:newValue)) ?? "0"
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
        }
        if let result = brain.result {
            displayValue = result
        }
        historyLabel.text = (brain.description ?? " ") + (brain.resultIsPending ? " ..." : " =")
    }
    
    // A user touched the "C" button
    @IBAction func touchReset(_ sender: UIButton) {
        displayValue = 0
        historyLabel.text = " "
        brain.reset()
        userIsInTheMiddleOfTyping = false
        userTypedDecimalPoint = false
    }
    
    // A user touched the "Backspace" button
    @IBAction func touchBackspace(_ sender: UIButton) {
        guard userIsInTheMiddleOfTyping && !display.text!.isEmpty else {
            return
        }
        display.text = String(display.text!.characters.dropLast())
        if display.text!.isEmpty {
            displayValue = 0
        }
    }
}

