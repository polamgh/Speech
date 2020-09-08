//
//  ViewController.swift
//  Speech
//
//  Created by Ali Ghanavati on 6/18/1399 AP.
//  Copyright © 1399 AP Ali Ghanavati. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController , AVSpeechSynthesizerDelegate  {

    @IBOutlet weak var btnLang: UIButton!
    @IBOutlet weak var txtDelay: UILabel!
    @IBOutlet weak var delaySlider: UISlider!
    @IBOutlet weak var btnSpeech: UIButton!
    @IBOutlet weak var txtText: UITextView!
    var delay : Int = 0
    var isSpeech = false
    var lang = "en-UK"
    let  synthesizer = AVSpeechSynthesizer()
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.string(forKey: "Lang") ?? "" == "en-UK" {
            btnLang.setTitle("British", for: .normal)
            self.lang = UserDefaults.standard.string(forKey: "Lang") ?? "en-UK"
        }else{
            btnLang.setTitle("American", for: .normal)
            self.lang = UserDefaults.standard.string(forKey: "Lang") ?? "en-US"
        }
    }
  
    override func viewWillAppear(_ animated: Bool) {
        delaySlider.setValue(Float(UserDefaults.standard.integer(forKey: "Delay")), animated: true)
       
        self.delay = UserDefaults.standard.integer(forKey: "Delay")
        txtDelay.text = "\(self.delay) Seconds"
        
        
        
        self.txtText.text = UserDefaults.standard.string(forKey: "Text")
    }
    
    @IBAction func btnLang(_ sender: UIButton) {
        self.lang = UserDefaults.standard.string(forKey: "Lang") ?? "en-UK"
          if lang == "en-UK" {
              btnLang.setTitle("American", for: .normal)
              self.lang = "en-US"
              UserDefaults.standard.set("en-US", forKey: "Lang")
          }else{
              btnLang.setTitle("British", for: .normal)
              self.lang = "en-UK"
              UserDefaults.standard.set("en-UK", forKey: "Lang")
          }
        
      }

    @IBAction func delaySlider(_ sender: UISlider) {
        txtDelay.text = "\(Int(sender.value)) Seconds"
        if self.delay != Int(sender.value){
            UserDefaults.standard.set(Int(sender.value), forKey: "Delay")
            self.delay = Int(sender.value)
        }
    }
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
//        let mutableAttributedString = NSMutableAttributedString(string: utterance.speechString)
//        mutableAttributedString.addAttribute(.foregroundColor, value: UIColor.red, range: characterRange)
////        txtText.attributedText = mutableAttributedString
//    }
//
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
////        txtText.attributedText = NSAttributedString(string: utterance.speechString)
//        isSpeech = false
//        btnSpeech.setTitle("Speech", for: .normal)
//    }
    @IBAction func speak(_ sender: UIButton) {
        self.view.endEditing(true)
        UserDefaults.standard.set(self.txtText.text ?? "" , forKey: "Text")
        if !isSpeech {
            speak((txtText.text ?? "").words)
            sender.setTitle("Stop", for: .normal)
            isSpeech = true
        }else{
            synthesizer.stopSpeaking(at: .immediate)
            sender.setTitle("Speech", for: .normal)
            isSpeech = false
        }
    }
    func speak(_ phrases: [String] ) {
        if let (phrase) = phrases.first {
            delay(Double(self.delay)) {
                let speechUtterance = AVSpeechUtterance(string: phrase)
                speechUtterance.voice = AVSpeechSynthesisVoice(language: self.lang)
                self.synthesizer.delegate =  self
                self.synthesizer.speak(speechUtterance)
                let rest = Array(phrases.dropFirst())
                if !rest.isEmpty {
                    if self.isSpeech {
                        self.speak(rest)
                    }else{
                        return
                    }
                }
            }
        }
        
    }
    func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
}

extension String {
    var words: [String] {
        return components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
    }
}
