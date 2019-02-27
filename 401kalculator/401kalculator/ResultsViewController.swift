//
//  ResultsViewController.swift
//  401kalculator
//
//  Created by Kyle Brennan on 2/26/19.
//  Copyright © 2019 BottleRocket. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var suggestedTraditionalPercentLabel: UILabel!
    @IBOutlet private weak var suggestedRothPercentLabel: UILabel!
    @IBOutlet private weak var newTakeHomeEstimateLabel: UILabel!
    @IBOutlet private weak var newTakeHomeTitleLabel: UILabel!
    @IBOutlet private weak var traditionalContainerView: UIView!
    @IBOutlet private weak var rothContainerView: UIView!
    @IBOutlet private weak var takeHomeContainerView: UIView!

    struct Configuration {
        let title: String?
        let traditionalPercent: Double
        let rothPercent: Double
        let newTakeHome: Double
    }

    private var titleString: String?
    private var traditionalPercent: Double?
    private var rothPercent: Double?
    private var newTakeHome: Double?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "401kalculator"
        navigationItem.backBarButtonItem?.title = ""
        
        setupViews()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.animateViews()
        })
    }

    func setupViews() {
        traditionalContainerView.layer.cornerRadius = traditionalContainerView.frame.width / 2
        rothContainerView.layer.cornerRadius = rothContainerView.frame.width / 2
        takeHomeContainerView.layer.cornerRadius = takeHomeContainerView.frame.width / 2

        if let titleString = titleString {
            titleLabel.text = titleString
        }

        if let traditionalPercent = traditionalPercent {
            suggestedTraditionalPercentLabel.text = String(format: "%.0f %%", traditionalPercent * 100)
        } else {
            suggestedTraditionalPercentLabel.text = "0 %"
        }

        if let rothPercent = rothPercent {
            suggestedRothPercentLabel.text = String(format: "%.0f %%", rothPercent * 100)
        } else {
            suggestedRothPercentLabel.text = "0 %"
        }

        if let newTakeHome = newTakeHome {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.locale = Locale.current
            numberFormatter.maximumFractionDigits = 0

            if let formattedTakeHome = numberFormatter.string(from: NSNumber(value: newTakeHome)) {
                newTakeHomeEstimateLabel.text = "$ \(formattedTakeHome)"
            } else {
                newTakeHomeEstimateLabel.text = String(format: "$ %.0f", newTakeHome)
            }
        } else {
            newTakeHomeEstimateLabel.isHidden = true
            newTakeHomeTitleLabel.isHidden = true
        }
    }

    func animateViews() {
        traditionalContainerView.frame.origin.x -= UIScreen.main.bounds.width
        rothContainerView.frame.origin.x += UIScreen.main.bounds.width
        takeHomeContainerView.frame.origin.y += UIScreen.main.bounds.height

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.traditionalContainerView.frame.origin.x += UIScreen.main.bounds.width
            self.rothContainerView.frame.origin.x -= UIScreen.main.bounds.width
            self.takeHomeContainerView.frame.origin.y -= UIScreen.main.bounds.height

            self.traditionalContainerView.isHidden = false
            self.rothContainerView.isHidden = false
            self.takeHomeContainerView.isHidden = self.newTakeHome == nil
        }) { _ in }
    }

    func configure(_ configuration: Configuration) {
        titleString = configuration.title
        traditionalPercent = configuration.traditionalPercent
        rothPercent = configuration.rothPercent
        newTakeHome = configuration.newTakeHome
    }
}
