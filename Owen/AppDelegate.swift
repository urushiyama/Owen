//
//  AppDelegate.swift
//  Owen
//
//  Created by urushiyama on 2019/D/16.
//  Copyright © 2019 urushiyama. All rights reserved.
//

import Cocoa

class BindedMenuItem: NSMenuItem, Bindable {
  func onBindedValueChanged(value: Bool) {
    self.state = value ? .on : .off
  }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var statusBarMenu: NSMenu!
  let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
  
  @IBOutlet weak var praiseForTypingWordsMenuItem: BindedMenuItem!
  @IBOutlet weak var praiseForEnteringLinesMenuItem: BindedMenuItem!
  @IBOutlet weak var praiseForUsingShortcutsMenuItem: BindedMenuItem!
  @IBOutlet weak var encourageAgainstDeletingWordsMenuItem: BindedMenuItem!
  @IBOutlet weak var encourageAgainstStoppingTypingMenuItem: BindedMenuItem!
  
  @Binding var praiseForTypingWords: Bool = true
  let praiseSentencesForTypingWords: [String] = [
    "ナイスペース！",
    "いいね，その調子だよ！",
    "いいペースだね！",
    "ノッてるね！",
    "よし，どんどんいこう！",
    "グッドワーク！"
  ]
  
  @Binding var praiseForEnteringLines: Bool = true
  let praiseSentencesForEnteringLines: [String] = [
    "その調子！",
    "オッケー！",
    "やったね！",
    "いいよ！",
    "いいね！",
    "ナイス！",
    "よくできました！",
    "えらいね！"
  ]
  
  @Binding var praiseForUsingShortcuts: Bool = true
  let praiseSentencesForUsingShortcuts: [String] = [
    "クレバー！",
    "ナイスショートカット！",
    "かっこいいよ！",
    "時短の天才だね！",
    "すばらしいよ！",
    "キレッキレだね！",
    "まるで指先の魔術師だよ！"
  ]
  
  @Binding var encourageAgainstDeletingWords: Bool = true
  let encourageSentencesAgainstDeletingWords: [String] = [
    "あせらずいこう．",
    "千里の道も一歩から，だよ．",
    "おちついていこう．",
    "気楽にいこう．",
    "大丈夫だよ！"
  ]
  
  @Binding var encourageAgainstStoppingTyping: Bool = true
  let encourageSentencesAgainstStoppingTyping: [String] = [
    "たまにはストレッチしよう．",
    "無理しないでね．",
    "あきらめなければなんとかなるさ．",
    "そろそろ休憩しよう．",
    "ここで一息リフレッシュだよ！"
  ]
  let suggestRestSentences: [String] = [
    "ゆっくり休もう．",
    "自分の時間を大切にしてね．",
    "自分のペースを大事にしよう．",
    "そろそろ休憩しよう．",
    "よく頑張ったね！"
  ]
  
  var deletes = 0
  let deleteThreshold = 16
  
  var returns = 0
  let returnsThreshold = 0
  
  var types = 0
  let typesPraiseThreshold = 75 * 5 // CPM
  let typesEncourageThreshold = 5 * 5 // CPM
  
  var stops = 0
  let stopsThreshold = 5
  
  var modifiers = 0
  let modifiersThreshold = 5
  
  var typingTimer: Timer? = nil
  var isTypingStopped: Bool = false
  
  var speechSynthesizer: NSSpeechSynthesizer? = nil

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    if !acquirePrivileges() {
      NSApp.terminate(self)
    }
    
    speechSynthesizer = NSSpeechSynthesizer(voice: NSSpeechSynthesizer.defaultVoice)
    speechSynthesizer?.rate = 240
    speechSynthesizer?.volume = 0.8
    
    // Start getting key-typing
    NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { (event: NSEvent!) in
//      var message = "Global Keydown: \(event.characters!) (\(event.keyCode)) "
//      if event.modifierFlags.contains(.capsLock) { message += "⇪" }
//      if event.modifierFlags.contains(.command)  { message += "⌘" }
//      if event.modifierFlags.contains(.control)  { message += "⌃" }
//      if event.modifierFlags.contains(.function) { message += "fn" }
//      if event.modifierFlags.contains(.option)   { message += "⌥" }
//      if event.modifierFlags.contains(.shift)    { message += "⇧" }
//      print(message)
      
      if self.encourageAgainstDeletingWords && event.keyCode == 51 {
        self.deletes += 1
        if self.deletes > self.deleteThreshold {
          // TODO: 大丈夫？無理しないでね，などの励ます言葉再生
          self.speechSynthesizer?.startSpeaking(self.encourageSentencesAgainstDeletingWords.shuffled().first!)
          self.deletes = 0
        }
      }
      
      if self.praiseForEnteringLines && event.keyCode == 36 {
        self.returns += 1
        if self.returns > self.returnsThreshold {
          // TODO: キレッキレ！いいね！などのほめる言葉再生
          self.speechSynthesizer?.startSpeaking(self.praiseSentencesForEnteringLines.shuffled().first!)
          self.returns = 0
        }
      }
      
      if self.praiseForUsingShortcuts && !event.modifierFlags.union(NSEvent.ModifierFlags([.command, .control, .option])).isEmpty {
        self.modifiers += 1
        if self.modifiers > self.modifiersThreshold {
          // TODO: ナイスショートカット！クレバー！などのほめる言葉再生
          self.speechSynthesizer?.startSpeaking(self.praiseSentencesForUsingShortcuts.shuffled().first!)
          self.modifiers = 0
        }
      }
      
      if event.characters != nil {
        self.types += 1
        self.isTypingStopped = false
      }
    }
    
    statusItem.menu = statusBarMenu
    statusItem.button?.title = "Owen"
    
    $praiseForTypingWords.bind(object: praiseForTypingWordsMenuItem)
    $praiseForEnteringLines.bind(object: praiseForEnteringLinesMenuItem)
    $praiseForUsingShortcuts.bind(object: praiseForUsingShortcutsMenuItem)
    $encourageAgainstDeletingWords.bind(object: encourageAgainstDeletingWordsMenuItem)
    $encourageAgainstStoppingTyping.bind(object: encourageAgainstStoppingTypingMenuItem)
    
    praiseForTypingWords = true
    praiseForEnteringLines = true
    praiseForUsingShortcuts = false
    encourageAgainstDeletingWords = true
    encourageAgainstStoppingTyping = true
    
    typingTimer = Timer.scheduledTimer(withTimeInterval: NSMeasurement(doubleValue: 1, unit: UnitDuration.minutes).converting(to: UnitDuration.seconds).value, repeats: true, block: feedbackTyping(_:))
  }
  
  func feedbackTyping(_ timer: Timer) {
    if praiseForTypingWords && types > typesPraiseThreshold && stops <= stopsThreshold {
      // TODO: 進捗モリモリ！ナイスペース！などのほめる言葉再生
      self.speechSynthesizer?.startSpeaking(praiseSentencesForTypingWords.shuffled().first!)
    }
    if encourageAgainstStoppingTyping && types < typesEncourageThreshold && !isTypingStopped {
      // TODO: 疲れたら休もう．などの休憩を促す言葉再生
      isTypingStopped = true
      stops += 1
      if stops > stopsThreshold {
        // TODO: 休憩を促す言葉再生
        self.speechSynthesizer?.startSpeaking(suggestRestSentences.shuffled().first!)
        if stops > Int.max - 1 { stops = Int.max - 1 }
      } else {
        // TODO: 進捗を励ます言葉再生
        self.speechSynthesizer?.startSpeaking(encourageSentencesAgainstStoppingTyping.shuffled().first!)
      }
    }
    types = 0
  }

  func applicationWillTerminate(_ aNotification: Notification) {
  }
  
  func acquirePrivileges() -> Bool {
    let accessEnabled = AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary)
    
    if accessEnabled != true {
      print("Need to enable the keylogger.")
    }
    
    return accessEnabled
  }
  
  @IBAction func statusBarBindedMenuItemSelected(_ sender: BindedMenuItem) {
    switch sender {
    case praiseForTypingWordsMenuItem:
      praiseForTypingWords.toggle()
    case praiseForEnteringLinesMenuItem:
      praiseForEnteringLines.toggle()
    case praiseForUsingShortcutsMenuItem:
      praiseForUsingShortcuts.toggle()
    case encourageAgainstDeletingWordsMenuItem:
      encourageAgainstDeletingWords.toggle()
    case encourageAgainstStoppingTypingMenuItem:
      encourageAgainstStoppingTyping.toggle()
    default: break
    }
  }
}
