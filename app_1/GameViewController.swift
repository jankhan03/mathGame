//
//  ViewController.swift
//  app_1
//
//  Created by Yan Khanetski on 14.08.21.
//

import UIKit
import AVFoundation

class GameViewController: UIViewController {

    var audioPlay: AVAudioPlayer?
    
    
    @IBOutlet weak var scoreLabel:UILabel?
    @IBOutlet weak var timeLabel:UILabel?
    @IBOutlet weak var numberLabel:UILabel?
    @IBOutlet weak var inputField:UITextField?
 //   @IBOutlet var inputFieldBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var inputFieldBottomConstraint: NSLayoutConstraint!
    var score = 0
    var timer:Timer?
    var seconds = 120
    var inputFieldBottom: CGFloat = 0
    
     
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateScoreLabel()
        updateNumberLabel()
        updateTimeLabel()
        
        let alertMessage = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertController.Style.alert)
        
        self.inputField?.layer.cornerRadius = 20
        self.inputField?.layer.masksToBounds = true
        
        inputFieldBottomConstraint.constant = self.view.bounds.size.height * 0.3
        
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard(with:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didShowKeyboard(with:)), name: UIWindow.keyboardDidHideNotification, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardDidHideNotification, object: nil)
    }
    
    @objc func willShowKeyboard(with notification: Notification) {
        print("Keyboard will Show")
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.size.height
            inputFieldBottom = inputFieldBottomConstraint.constant
            inputFieldBottomConstraint.constant = keyboardHeight + 16
        }
        
    }
    
    @objc func didShowKeyboard(with notification: Notification) {
        inputFieldBottomConstraint.constant = inputFieldBottom
    }
    
    func updateScoreLabel() {
        scoreLabel?.text = String(score)
    }
    
    func updateNumberLabel() {
        numberLabel?.text = String.randomNumber(length: 4)
    }
    
    func updateTimeLabel() {

        let min = (seconds / 60) % 60
        let sec = seconds % 60

        timeLabel?.text = String(format: "%02d", min) + ":" + String(format: "%02d", sec)
    }
    
    @IBAction func inputFieldDidChange() {
            guard let numberText = numberLabel?.text, let inputText = inputField?.text else {
                return
            }
            guard inputText.count == 4 else {
                return
            }
            
            var isCorrect = true

            for n in 0..<4 {
                var input = inputText.integer(at: n)
                let number = numberText.integer(at: n)
                
                if input == 0 {
                    input = 10
                }
                if input != number + 1 {
                    isCorrect = false
                    break
                }
            }
        
            if isCorrect {
                score += 1
                let selectedInstrument = score
                
                let pathToSound = Bundle.main.path(forResource: "win", ofType: "wav")!
                let url = URL(fileURLWithPath: pathToSound)
                
                do{
                    audioPlay = try AVAudioPlayer(contentsOf: url)
                    audioPlay?.play()
                } catch {
                    //
                }
               // allertMessage(title: "👍", message: "Correct")
            } else {
                score -= 1
                let selectedInstrument = score
                
                let pathToSound = Bundle.main.path(forResource: "lose", ofType: "wav")!
                let url = URL(fileURLWithPath: pathToSound)
                
                do{
                    audioPlay = try AVAudioPlayer(contentsOf: url)
                    audioPlay?.play()
                } catch {
                    //
                }
               // allertMessage(title: "👎", message: "Uncorrect")
            }
            
        
        
            updateNumberLabel()
            updateScoreLabel()
            inputField?.text = ""

            if self.timer == nil {
                    self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                        
                        if self.seconds == 0 {
                              self.finishGame()
                          } else if self.seconds <= 120 {
                              self.seconds -= 1
                              self.updateTimeLabel()
                          } else if self.seconds <= 30 {
                            self.timeLabel?.textColor = .red
                          }
                        
                        
                        if self.score >= 10 {
                            self.timer?.invalidate()
                            
                            self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                                
                                if self.seconds == 0 {
                                    self.finishGame()
                                } else if self.seconds <= 120 {
                                    self.seconds -= 1
                                    self.updateTimeLabel()
                                } else if self.seconds <= 30 {
                                    self.timeLabel?.textColor = .red
                                }
                            }
                        }
                    }
                }
        }
        
    func finishGame() {
        timer?.invalidate()
        timer = nil
        let alert = UIAlertController(title: "Time's Up!", message: "Your time is up! You got a score of \(score) points. Awesome!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK, start new game", style: .default, handler: nil))

        self.present(alert, animated: true, completion: nil)
        score = 0
        seconds = 120
        
        updateTimeLabel()
        updateScoreLabel()
        updateNumberLabel()
    }
}

