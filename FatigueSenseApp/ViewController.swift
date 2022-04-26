/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import CoreBluetooth

let heartRateServiceCBUUID = CBUUID(string: "180D")
let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37")
let bodySensorLocationCharacteristicCBUUID = CBUUID(string: "2A38")

let respiratoryRateServiceCBUUID = CBUUID(string: "33bd9a27-ccfd-46a9-b871-7ea59b8bffcc")
let respiratoryRateMeasurementCharacteristicCBUUID = CBUUID(string: "e1eb67a5-9a8a-4ad2-890b-9b6b3d510487")

let galvanicSkinResponseServiceCBUUID = CBUUID(string: "c4b46587-9ec5-45cb-bc7c-6fe34d6a284b")
let galvanicSkinResponseMeasurementCharacteristicCBUUID = CBUUID(string: "dad10ea5-9098-4e09-80aa-4f666cca2de5")

let fatigueServiceCBUUID = CBUUID(string: "7732a999-7021-47eb-b15d-c5f8b333b8e0")
let fatigueMeasurementCharacteristicCBUUID = CBUUID(string: "11a29f6f-8596-4e47-8d56-00302ad5e577")

class FSViewController: UIViewController {

  @IBOutlet weak var heartRateLabel: UILabel!
  @IBOutlet weak var heartRateVariabilityLabel: UILabel!
  @IBOutlet weak var bodySensorLocationLabel: UILabel!
  
  @IBOutlet weak var respiratoryRateLabel: UILabel!
  @IBOutlet weak var respiratoryIntensityLabel: UILabel!
  
  @IBOutlet weak var galvanicSkinResponseLabel: UILabel!
  
  @IBOutlet weak var fatigueLabel: UILabel!

  var centralManager: CBCentralManager!
  var heartRatePeripheral: CBPeripheral!

  override func viewDidLoad() {
    super.viewDidLoad()

    centralManager = CBCentralManager(delegate: self, queue: nil)

    // Make the digits monospaces to avoid shifting when the numbers change
    //heartRateLabel.font = UIFont.monospacedDigitSystemFont(ofSize: heartRateLabel.font!.pointSize, weight: .regular)
    //heartRateVariabilityLabel.font = UIFont.monospacedDigitSystemFont(ofSize: heartRateLabel.font!.pointSize, weight: .regular)
  }

  func onHeartRateReceived(_ heartRate: Int, heartRateVariability: Float) {
    heartRateLabel.text = String(heartRate)
    heartRateVariabilityLabel.text = String(heartRateVariability)
    print("Heart Rate: \(heartRate)")
    print("HRV:        \(heartRateVariability)")
  }
  
  func onRespiratoryRateReceived(_ respiratoryRate: Int, respiratoryIntensity: Int) {
    if respiratoryRate < 5 {
      respiratoryRateLabel.text = String("--")
    }
    else if respiratoryRate < 11 {
      respiratoryRateLabel.text = String("5-11")
    }
    else if respiratoryRate < 17 {
      respiratoryRateLabel.text = String("12-16")
    }
    else if respiratoryRate < 23 {
      respiratoryRateLabel.text = String("17-22")
    }
    else if respiratoryRate < 29 {
      respiratoryRateLabel.text = String("23-28")
    }
    else if respiratoryRate < 35 {
      respiratoryRateLabel.text = String("29-34")
    }
    else {
      respiratoryRateLabel.text = String("High")
    }
    //respiratoryRateLabel.text = String(respiratoryRate)
    
    if respiratoryIntensity == 0 {
      respiratoryIntensityLabel.text = String("Normal")
    }
    else {
      respiratoryIntensityLabel.text = String("Shallow")
    }
    //respiratoryIntensityLabel.text = String(respiratoryIntensity)
    
    print("Resp Rate:  \(respiratoryRate)")
    print("Intensity:  \(respiratoryIntensity)")
  }
  
  func onGalvanicSkinRateReceived(_ galvanicSkinResponse: Float) {
    galvanicSkinResponseLabel.text = String("--")
    //galvanicSkinResponseLabel.text = String(galvanicSkinResponse)
    print("GSR:        \(galvanicSkinResponse)")
  }
  
  func onFatigueReceived(_ fatigued: Int) {
    if fatigued > 0 {
      fatigueLabel.text = String("Fatigued")
    }
    else {
      fatigueLabel.text = String("")
    }
    print("Fatigue:    \(fatigued)")
  }
}

extension FSViewController: CBCentralManagerDelegate {
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch central.state {
    case .unknown:
      print("central.state is .unknown")
    case .resetting:
      print("central.state is .resetting")
    case .unsupported:
      print("central.state is .unsupported")
    case .unauthorized:
      print("central.state is .unauthorized")
    case .poweredOff:
      print("central.state is .poweredOff")
    case .poweredOn:
      print("central.state is .poweredOn")
      centralManager.scanForPeripherals(withServices: [fatigueServiceCBUUID])
    @unknown default:
      print("central.state is .unknown")
    }
  }

  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                      advertisementData: [String : Any], rssi RSSI: NSNumber) {
    print(peripheral)
    heartRatePeripheral = peripheral
    heartRatePeripheral.delegate = self
    centralManager.stopScan()
    centralManager.connect(heartRatePeripheral)
  }

  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    print("Connected!")
    heartRatePeripheral.discoverServices([heartRateServiceCBUUID, respiratoryRateServiceCBUUID, galvanicSkinResponseServiceCBUUID, fatigueServiceCBUUID])
  }
}

extension FSViewController: CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    guard let services = peripheral.services else { return }
    for service in services {
      print(service)
      peripheral.discoverCharacteristics(nil, for: service)
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    guard let characteristics = service.characteristics else { return }

    for characteristic in characteristics {
      print(characteristic)

      if characteristic.properties.contains(.read) {
        print("\(characteristic.uuid): properties contains .read")
        peripheral.readValue(for: characteristic)
      }
      if characteristic.properties.contains(.notify) {
        print("\(characteristic.uuid): properties contains .notify")
        peripheral.setNotifyValue(true, for: characteristic)
      }
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    switch characteristic.uuid {
    case bodySensorLocationCharacteristicCBUUID:
      let bodySensorLocation = bodyLocation(from: characteristic)
      //bodySensorLocationLabel.text = bodySensorLocation
    case heartRateMeasurementCharacteristicCBUUID:
      let bpm = heartRate(from: characteristic)
      let hrv = heartRateVariability(from: characteristic)
      onHeartRateReceived(bpm, heartRateVariability: hrv)
    case respiratoryRateMeasurementCharacteristicCBUUID:
      let respRate = respiratoryRate(from: characteristic)
      let respIntensity = respiratoryIntensity(from: characteristic)
      onRespiratoryRateReceived(respRate, respiratoryIntensity: respIntensity)
    case galvanicSkinResponseMeasurementCharacteristicCBUUID:
      let gsr = galvanicSkinResponse(from: characteristic)
      onGalvanicSkinRateReceived(gsr)
    case fatigueMeasurementCharacteristicCBUUID:
      let fatigued = fatigueIndicator(from: characteristic)
      onFatigueReceived(fatigued)
    default:
      print("Unhandled Characteristic UUID: \(characteristic.uuid)")
    }
  }

  private func bodyLocation(from characteristic: CBCharacteristic) -> String {
    guard let characteristicData = characteristic.value,
      let byte = characteristicData.first else { return "Error" }

    switch byte {
    case 0: return "Other"
    case 1: return "Chest"
    case 2: return "Wrist"
    case 3: return "Finger"
    case 4: return "Hand"
    case 5: return "Ear Lobe"
    case 6: return "Foot"
    default:
      return "Reserved for future use"
    }
  }

  private func heartRate(from characteristic: CBCharacteristic) -> Int {
    guard let characteristicData = characteristic.value else { return -1 }
    let byteArray = [UInt8](characteristicData)

    // See: https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.heart_rate_measurement.xml
    // The heart rate mesurement is in the 2nd, or in the 2nd and 3rd bytes, i.e. one one or in two bytes
    // The first byte of the first bit specifies the length of the heart rate data, 0 == 1 byte, 1 == 2 bytes
    let firstBitValue = byteArray[0] & 0x01
    if firstBitValue == 0 {
      // Heart Rate Value Format is in the 2nd byte
      return Int(byteArray[1])
    } else {
      // Heart Rate Value Format is in the 2nd and 3rd bytes
      return (Int(byteArray[2]) << 8) + Int(byteArray[1])
    }
  }
  
  private func heartRateVariability(from characteristic: CBCharacteristic) -> Float {
    guard let characteristicData = characteristic.value else { return -1 }
    let byteArray = [UInt8](characteristicData)
    var combinedValue: Int

    // See: https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.heart_rate_measurement.xml
    // The first byte of the first bit specifies the length of the heart rate data, 0 == 1 byte, 1 == 2 bytes
    let firstBitValue = byteArray[0] & 0x01
    if firstBitValue == 0 {
      // Heart Rate Variability Value Format is in the 3rd and 4th bytes
      combinedValue = (Int(byteArray[3]) << 8) + Int(byteArray[2])
    } else {
      // Heart Rate Variability Value Format is in the 4th and 5th bytes
      combinedValue = (Int(byteArray[4]) << 8) + Int(byteArray[3])
    }
    return Float(combinedValue)/1024.0
  }
  
  private func respiratoryRate(from characteristic: CBCharacteristic) -> Int {
    guard let characteristicData = characteristic.value else { return -1 }
    let byteArray = [UInt8](characteristicData)

    // Respiratory Rate Value Format is in the 1st and 2nd bytes
    return (Int(byteArray[1]) << 8) + Int(byteArray[0])
  }
  
  private func respiratoryIntensity(from characteristic: CBCharacteristic) -> Int {
    guard let characteristicData = characteristic.value else { return -1 }
    let byteArray = [UInt8](characteristicData)

    // Respiratory Intensity Value Format is in the 3rd byte
    return (Int(byteArray[2]))
  }
  
  private func galvanicSkinResponse(from characteristic: CBCharacteristic) -> Float {
    guard let characteristicData = characteristic.value else { return -1 }
    let byteArray = [UInt8](characteristicData)
    
    let combinedValue = (Int(byteArray[1]) << 8) + Int(byteArray[0])

    return Float(combinedValue)/24.0 //TODO correct divider value
  }
  
  private func fatigueIndicator(from characteristic: CBCharacteristic) -> Int {
    guard let characteristicData = characteristic.value else { return -1 }
    let byteArray = [UInt8](characteristicData)

    return Int(byteArray[0])
  }
}
