//
//  Bindable.swift
//  Owen
//
//  Created by urushiyama on 2019/D/16.
//  Copyright © 2019 urushiyama. All rights reserved.
//

import Cocoa

protocol Bindable {
  associatedtype BindedType
  func onBindedValueChanged(value: BindedType) -> Void
}

@propertyWrapper
struct Binding<Value> {
  var value: Value
  private var callbacks: [((Value) -> Void)] = []
  
  init(wrappedValue: Value) {
    self.value = wrappedValue
  }
  
  var wrappedValue: Value {
    get { value }
    
    set {
      value = newValue
      callbacks.forEach { $0(newValue) }
    }
  }
  
  var projectedValue: Binding<Value> {
    get { self }
    set { self = newValue }
  }
  
  public mutating func bind(didChange: @escaping (Value) -> Void) {
    callbacks.append(didChange)
  }
  
  public mutating func bind<T: Bindable>(object: T) where T.BindedType == Value {
    callbacks.append(object.onBindedValueChanged(value:))
  }
}
