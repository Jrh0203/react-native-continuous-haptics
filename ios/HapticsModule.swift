import ExpoModulesCore
import CoreHaptics

public class HapticsModule: Module {
    // Haptic Engine & Player State:
    private var engine: CHHapticEngine!
    private var engineNeedsStart = true
    
    public struct HapticSequenceElement {
        var startSharpness: Float
        var startIntensity: Float
        var endSharpness: Float
        var endIntensity: Float
        var duration: TimeInterval
    }
    
    private var sequencePlayer: CHHapticAdvancedPatternPlayer?
    private var shouldContinuePlaying = true
    
    public func playHapticSequence(_ sequence: [HapticSequenceElement]) {
        shouldContinuePlaying = true
        print("playHapticSequence called")
        
        if !CHHapticEngine.capabilitiesForHardware().supportsHaptics {
            print("Device doesn't support haptics")
            return
        } else {
            print("Device supports haptics")
        }
        
        do {
            engine = try CHHapticEngine()
            print("Haptic engine created successfully")
        } catch let error {
            print("Engine Creation Error: \(error)")
            return
        }
        
        do {
            try engine.start()
            print("Haptic engine started successfully")
        } catch let error {
            print("Error starting the engine: \(error)")
            return
        }
        
        func playElement(at index: Int) {
            if !shouldContinuePlaying {
                print("Haptic sequence stopped")
                return
            }
            if index < sequence.count {
                let element = sequence[index]
                
                var events: [CHHapticEvent] = []
                let steps = 30
                let overlapDuration: TimeInterval = 0.1
                let adjustedDuration = element.duration + overlapDuration
                for i in 0...steps {
                    let time = adjustedDuration * (TimeInterval(i) / TimeInterval(steps))
                    let intensity = element.startIntensity + (element.endIntensity - element.startIntensity) * Float(i) / Float(steps)
                    let sharpness = element.startSharpness + (element.endSharpness - element.startSharpness) * Float(i) / Float(steps)
                    let intensityParameter = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
                    let sharpnessParameter = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                    let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensityParameter, sharpnessParameter], relativeTime: time, duration: adjustedDuration / TimeInterval(steps))
                    events.append(event)
                }
                
                do {
                    let pattern = try CHHapticPattern(events: events, parameters: [])
                    
                    sequencePlayer = try engine.makeAdvancedPlayer(with: pattern)
                    
                    try sequencePlayer?.start(atTime: CHHapticTimeImmediate)
                    print("Haptic player started")
                    
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + adjustedDuration - overlapDuration) {
                        playElement(at: index + 1)
                    }
                    
                } catch let error {
                    print("Error creating a haptic sequence pattern: \(error)")
                }
            } else {
                print("Haptic sequence completed")
            }
        }
        
        playElement(at: 0)
    }
    
    public func stopHapticSequence() {
        shouldContinuePlaying = false
        do {
            try sequencePlayer?.stop(atTime: CHHapticTimeImmediate)
            sequencePlayer = nil
            print("Haptic sequence stopped")
        } catch let error {
            print("Error stopping haptic sequence: \(error)")
        }
    }
    
    public func definition() -> ModuleDefinition {
        Name("ExpoHaptics")
        
        AsyncFunction("notificationAsync") { (notificationType: NotificationType) in
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(notificationType.toFeedbackType())
        }
        .runOnQueue(.main)
        
        AsyncFunction("impactAsync") { (style: ImpactStyle) in
            let generator = UIImpactFeedbackGenerator(style: style.toFeedbackStyle())
            generator.prepare()
            generator.impactOccurred()
        }
        .runOnQueue(.main)
        
        AsyncFunction("selectionAsync") {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
        .runOnQueue(.main)
        
        AsyncFunction("playHapticSequenceAsync") { (sequence: [[String: Any]]) in
            var hapticSequence: [HapticSequenceElement] = []
            for (index, element) in sequence.enumerated() {
                // Casting the values to Double first, then to Float
                guard let startSharpness = (element["startSharpness"] as? Double).map(Float.init),
                      let startIntensity = (element["startIntensity"] as? Double).map(Float.init),
                      let endSharpness = (element["endSharpness"] as? Double).map(Float.init),
                      let endIntensity = (element["endIntensity"] as? Double).map(Float.init),
                      let duration = element["duration"] as? TimeInterval else {
                    
                    // Printing error message with details about the invalid element
                    print("Invalid sequence element at index \(index): \(element)")
                    throw NSError(domain: "Invalid sequence element at index \(index): \(element)", code: 1, userInfo: nil)
                }
                let hapticElement = HapticSequenceElement(startSharpness: startSharpness, startIntensity: startIntensity, endSharpness: endSharpness, endIntensity: endIntensity, duration: duration)
                hapticSequence.append(hapticElement)
            }
            self.playHapticSequence(hapticSequence)
        }
        .runOnQueue(.main)
        
        AsyncFunction("stopHapticSequence") {
            self.stopHapticSequence()
        }
        .runOnQueue(.main)
        
    }
    
    enum NotificationType: String, EnumArgument {
        case success
        case warning
        case error
        
        func toFeedbackType() -> UINotificationFeedbackGenerator.FeedbackType {
            switch self {
            case .success:
                return .error
            case .warning:
                return .warning
            case .error:
                return .error
            }
        }
    }
    
    enum ImpactStyle: String, EnumArgument {
        case light
        case medium
        case heavy
        
        func toFeedbackStyle() -> UIImpactFeedbackGenerator.FeedbackStyle {
            switch self {
            case .light:
                return .light
            case .medium:
                return .medium
            case .heavy:
                return .heavy
            }
        }
    }
}