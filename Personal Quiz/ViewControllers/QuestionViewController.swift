//
//  QuestionViewController.swift
//  Personal Quiz
//
//  Created by brubru on 19.07.2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import UIKit

class QuestionViewController: UIViewController {

    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var singleStackView: UIStackView!
    @IBOutlet var singleButtons: [UIButton]!
    
    @IBOutlet weak var multipleStackView: UIStackView!
    @IBOutlet var multipleLabels: [UILabel]!
    @IBOutlet var multipleSwitches: [UISwitch]!
    
    @IBOutlet weak var rangerdStackView: UIStackView!
    @IBOutlet var rangedLabels: [UILabel]!
    @IBOutlet weak var rangedSlider: UISlider! {
        didSet {
            let answerCount = Float(currenrAnswers.count - 1)
            
            rangedSlider.value = answerCount / 2
            rangedSlider.maximumValue = answerCount
        }
    }
    
    @IBOutlet weak var quedtionProgerssView: UIProgressView!
    
    private let questions = Question.getQuestions()
    private var questionIndex = 0
    private var currenrAnswers: [Answer] {
        questions[questionIndex].answers
    }
    private var answersChooser: [Answer] = []
    private var dogCount = 0
    private var catCount = 0
    private var rabbitCount = 0
    private var turtleCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
 
    @IBAction func singleAnnserButtonBressed(_ sender: UIButton) {
        guard let buttonIndex = singleButtons.firstIndex(of: sender) else { return }
        let currentAnswer = currenrAnswers[buttonIndex]
        answersChooser.append(currentAnswer)
        nextQuestion()
    }
    
    @IBAction func multipleAnserButtonBressed() {
        for (multipleSwitch, answer) in zip(multipleSwitches, currenrAnswers) {
            if multipleSwitch.isOn {
                answersChooser.append(answer)
            }
        }
        
        nextQuestion()
    }
    
    @IBAction func rangedAnswerButtonPressed() {
        let index = lrintf(rangedSlider.value)
        answersChooser.append(currenrAnswers[index])
        
        nextQuestion()
    }
}

// MARK: - Private Methods
extension QuestionViewController {
    private func setupUI() {
        for stackView in [singleStackView, multipleStackView, rangerdStackView] {
            stackView?.isHidden = true
        }
        
        let currentQuestion = questions[questionIndex]
        questionLabel.text = currentQuestion.title
        
        let totalProgress = Float(questionIndex) / Float(questions.count)
        quedtionProgerssView.setProgress(totalProgress, animated: true)
        
        title = "Вопрос № \(questionIndex + 1) из \(questions.count)"
        
        showCurrentAnswers(for: currentQuestion.type)
    }
    
    private func showCurrentAnswers(for type: ResponseType) {
        switch type {
        case .single: showSingleStackView(with: currenrAnswers)
        case .multiple: showMultipleStackView(with: currenrAnswers)
        case .ranged: showRangedStackView(with: currenrAnswers)
        }
    }
    
    private func showSingleStackView(with answers: [Answer]) {
        singleStackView.isHidden = false
        
        for (button, answer) in zip(singleButtons, answers) {
            button.setTitle(answer.title, for: .normal)
        }
    }
    
    private func nextQuestion() {
        questionIndex += 1
        
        if questionIndex < questions.count {
            setupUI()
            return
        }
        
        performSegue(withIdentifier: "resultSegue", sender: nil)
    }
    
    private func showMultipleStackView(with answers: [Answer]) {
        multipleStackView.isHidden = false
        
        for (label, answer) in zip(multipleLabels, answers) {
            label.text = answer.title
        }
    }
    
    private func showRangedStackView(with answers: [Answer]) {
        rangerdStackView.isHidden = false
        
        rangedLabels.first?.text = answers.first?.title
        rangedLabels.last?.text = answers.last?.title
    }
    
    private func countingAnswers(answers: [Answer]) {
        for answer in answers {
            switch answer.type{
            case .dog:
                dogCount += 1
            case .cat:
                catCount += 1
            case .rabbit:
                rabbitCount += 1
            case .turtle:
                turtleCount += 1
            }
        }
    }
    
    private func countingResults(answers: [Answer]) -> AnimalType {
        countingAnswers(answers: answers)
        let allCount = [dogCount, catCount, rabbitCount, turtleCount]
        let maxCount = allCount.max()
        switch maxCount {
        case dogCount:
            return .dog
        case catCount:
            return .cat
        case rabbitCount:
            return .rabbit
        case turtleCount:
            return .turtle
        case .none:
            return .turtle
        case .some(_):
            return .turtle
        }
    }
}

extension QuestionViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let resultVC = segue.destination as? ResultsViewController else { return }
        resultVC.results = countingResults(answers: answersChooser)
        
    }
}
