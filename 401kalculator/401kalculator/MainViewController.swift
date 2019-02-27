//
//  MainViewController.swift
//  401kalculator
//
//  Created by Kyle Brennan on 2/22/19.
//  Copyright © 2019 BottleRocket. All rights reserved.
//

import UIKit

enum InfoState {
    case currentSalary
    case traditionalContribution
    case rothContribution
    case newSalary

    var nextState: InfoState? {
        switch self {
        case .currentSalary:
            return .traditionalContribution
        case .traditionalContribution:
            return .rothContribution
        case .rothContribution:
            return .newSalary
        case .newSalary:
            return nil
        }
    }

    var question: String {
        switch self {
        case .currentSalary:
            return "What is your current total yearly salary?"
        case .traditionalContribution:
            return "What percent of your salary do you currently contribute to a traditional 401k?"
        case .rothContribution:
            return "What percent of your salary do you currently contribute to a Roth IRA?"
        case .newSalary:
            return "What is your new total yearly salary after your raise?"
        }
    }

    var showPercentSign: Bool {
        switch self {
        case .currentSalary:
            return false
        case .traditionalContribution:
            return true
        case .rothContribution:
            return true
        case .newSalary:
            return false
        }
    }
}

class MainViewController: UIViewController {
    
    @IBOutlet private weak var questionContainerView: UIView!
    @IBOutlet private weak var nextButton: UIButton!

    private var currentView: UIView?
    private var currentState: InfoState = .currentSalary
    private var amountsDict = [InfoState: Double]()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        title = "401kalculator"
        goToInitialState()
    }

    func goToInitialState() {
        for subview in questionContainerView.subviews {
            subview.removeFromSuperview()
        }

        currentState = .currentSalary

        let initialInputView = generateInputForm(withState: currentState)
        addAlignedSubview(initialInputView)
        currentView = initialInputView

        nextButton.setTitle("Next", for: .normal)
        nextButton.isEnabled = false
    }

    func generateInputForm(withState state: InfoState) -> InputFormView {
        let formView: InputFormView = .fromNib()
        formView.configure(InputFormView.Configuration(question: state.question, showPercentSign: state.showPercentSign))
        formView.delegate = self

        return formView
    }

    func goToNextState() {
        if let nextState = currentState.nextState {
            let nextForm = generateInputForm(withState: nextState)
            transition(toView: nextForm)

            currentState = nextState
            nextButton.isEnabled = false

            if currentState.nextState == nil {
                nextButton.setTitle("Finish", for: .normal)
            }
        } else {
            guard
                let currentSalary = amountsDict[InfoState.currentSalary],
                let traditionalContribution = amountsDict[InfoState.traditionalContribution],
                let rothContribution = amountsDict[InfoState.rothContribution],
                let newSalary = amountsDict[InfoState.newSalary],
                let newTraditionalPercent = newTraditionalPercentageSolver(currentSalary: currentSalary,
                                                                           currentTraditionalPercent: traditionalContribution / 100,
                                                                           currentRothPercent: rothContribution / 100,
                                                                           newSalary: newSalary)
            else {
                goToInitialState()
                return
            }

            let newRothPercent = newRothPercentageSolver(currentTraditionalPercent: traditionalContribution,
                                                         currentRothPercent: rothContribution,
                                                         newTraditionalPercent: newTraditionalPercent)
            let newTakeHomeEstimate = newTakeHomeSolver(newSalary: newSalary,
                                                        newTraditionalPercent: newTraditionalPercent,
                                                        newRothPercent: newRothPercent)

            if let resultsViewController: ResultsViewController = UIViewController.fromStoryboard("Main") {
                resultsViewController.configure(ResultsViewController.Configuration(title: nil,
                                                                                    traditionalPercent: newTraditionalPercent,
                                                                                    rothPercent: newRothPercent,
                                                                                    newTakeHome: newTakeHomeEstimate))
                navigationController?.pushViewController(resultsViewController, animated: true)
            } else {
                goToInitialState()
            }
        }
    }

    func transition(toView newView: UIView) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            if let currentView = self.currentView {
                currentView.frame.origin.x -= currentView.frame.width
            }
        }) { [weak self] _ in
            self?.currentView?.removeFromSuperview()

            self?.addAlignedSubview(newView)
            newView.frame.origin.x += newView.frame.width

            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                newView.frame.origin.x -= newView.frame.width
            }, completion: { [weak self] _ in
                self?.currentView = newView
            })
        }
    }

    func addAlignedSubview(_ subView: UIView) {
        questionContainerView.addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: subView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: questionContainerView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: subView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: questionContainerView, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: subView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: questionContainerView, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: -30).isActive = true
        NSLayoutConstraint(item: subView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: questionContainerView, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: -30).isActive = true
    }

    @IBAction func nextButtonTapped() {
        if let inputView = currentView as? InputFormView {
            amountsDict[currentState] = inputView.textFieldValue()
        }
        goToNextState()
    }

    @IBAction func refreshButtonTapped() {
        goToInitialState()
    }
    
    private func newTraditionalPercentageSolver(currentSalary: Double, currentTraditionalPercent: Double, currentRothPercent: Double, newSalary: Double) -> Double? {
        let a = currentRothPercent / currentTraditionalPercent
        let b = -(currentRothPercent / currentTraditionalPercent + 1)
        let c = 1 - (currentSalary * (1 - currentTraditionalPercent) * (1 - currentRothPercent)) / newSalary

        if a == 0 {
            return linearSolver(b: b, c: c)
        }

        guard let (ntp1, ntp2) = quadraticSolver(a: a, b: b, c: c) else { return nil }

        return chooseTraditionalPercent(ntp1, ntp2)
    }

    private func newRothPercentageSolver(currentTraditionalPercent: Double, currentRothPercent: Double, newTraditionalPercent: Double) -> Double {
        return currentRothPercent * newTraditionalPercent / currentTraditionalPercent
    }

    private func newTakeHomeSolver(newSalary: Double, newTraditionalPercent: Double, newRothPercent: Double) -> Double {
        return newSalary * (1 - newTraditionalPercent) * (1 - newRothPercent)
    }

    private func linearSolver(b: Double, c: Double) -> Double? {
        guard b != 0 else { return nil }

        return -(c / b)
    }

    private func quadraticSolver(a: Double, b: Double, c: Double) -> (Double, Double)? {
        let delta = deltaSolver(a: a, b: b, c: c)

        guard delta >= 0 else { return nil }

        let x1 = (-b + sqrt(delta)) / (2 * a)
        let x2 = (-b - sqrt(delta)) / (2 * a)

        return (x1, x2)
    }

    private func deltaSolver(a: Double, b: Double, c: Double) -> Double {
        return b * b - 4 * a * c
    }

    private func chooseTraditionalPercent(_ p1: Double, _ p2: Double) -> Double {
        if p1 > 1 && p2 < 1 {
            if p2 > 0 {
                return p2
            }
            return 0
        }
        if p1 < 1 && p2 > 1 {
            if p1 > 0 {
                return p1
            }
            return 0
        }
        if p1 < 1 && p2 < 1 && p1 > 0 && p2 > 0 {
            return max(p1, p2)
        }

        return 0
    }
}

extension MainViewController: InputFormViewDelegate {

    func textFieldIsSetValid(_ isValid: Bool) {
        nextButton.isEnabled = isValid
    }
}

extension UIView {

    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

extension UIViewController {

    class func fromStoryboard<T: UIViewController>(_ name: String) -> T? {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let controller: T? = storyboard.instantiateViewController(withIdentifier: String(describing: T.self)) as? T

        return controller
    }
}
