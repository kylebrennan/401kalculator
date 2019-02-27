//
//  InputFormView.swift
//  401kalculator
//
//  Created by Kyle Brennan on 2/25/19.
//  Copyright © 2019 BottleRocket. All rights reserved.
//

import UIKit

protocol InputFormViewDelegate: class {
    func textFieldIsSetValid(_ isValid: Bool)
}

class InputFormView: UIView {
    @IBOutlet private weak var containerStackView: UIStackView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var percentSignLabel: UILabel!
    @IBOutlet private weak var dollarSignLabel: UILabel!

    private var isViewLoaded = false
    private var question: String?
    private var showPercentSign: Bool = false

    private lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale.current
        numberFormatter.maximumFractionDigits = 0

        return numberFormatter
    }()

    weak var delegate: InputFormViewDelegate?

    struct Configuration {
        let question: String
        let showPercentSign: Bool
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        textField.delegate = self
        textField.addLine()
        textField.becomeFirstResponder()

        layer.cornerRadius = 10.0

        updateViews()

        isViewLoaded = true
    }

    func configure(_ configuration: Configuration) {
        question = configuration.question
        showPercentSign = configuration.showPercentSign

        if isViewLoaded {
            updateViews()
        }
    }

    func textFieldValue() -> Double? {
        guard var text = textField.text else { return nil }

        if let groupingSeparator = numberFormatter.groupingSeparator {
            text = text.replacingOccurrences(of: groupingSeparator, with: "")
        }

        return Double(text)
    }

    private func updateViews() {
        questionLabel.text = question
        percentSignLabel.isHidden = !showPercentSign
        dollarSignLabel.isHidden = !percentSignLabel.isHidden
    }
}

extension InputFormView: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }

        var isValid = true
        if showPercentSign {
            var totalText = text + string
            if string == "" {
                totalText.removeLast()
            }

            if let total = Int(totalText) {
                isValid = numberIsValidPercent(total)
            }
        }

        if text.count == 1 && string.count == 0 || !isValid {
            delegate?.textFieldIsSetValid(false)
        } else {
            delegate?.textFieldIsSetValid(true)
        }

        if !showPercentSign {
            if let groupingSeparator = numberFormatter.groupingSeparator {

                if let textWithoutGroupingSeparator = textField.text?.replacingOccurrences(of: groupingSeparator, with: "") {

                    var totalTextWithoutGroupingSeparators = textWithoutGroupingSeparator + string
                    if string == "" { // pressed Backspace key
                        totalTextWithoutGroupingSeparators.removeLast()
                    }
                    if
                        let numberWithoutGroupingSeparator = numberFormatter.number(from: totalTextWithoutGroupingSeparators),
                        let formattedText = numberFormatter.string(from: numberWithoutGroupingSeparator) {

                        textField.text = formattedText
                        return false
                    }
                }
            }
        }

        return true
    }

    func numberIsValidPercent(_ number: Int) -> Bool {
        return number <= 100
    }
}

extension UITextField {

    func addLine() {
        let lineView = UIView()
        lineView.backgroundColor = UIColor.darkGray
        lineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lineView)

        let metrics = ["width" : NSNumber(value: 0.5)]
        let views = ["lineView" : lineView]

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(width)]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
    }
}
