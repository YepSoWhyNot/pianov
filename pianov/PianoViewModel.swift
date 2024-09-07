import Foundation

struct Note: Identifiable {
    let id = UUID()
    let pitch: Int  // MIDI note number
    let startTime: Double
    let duration: Double
}

class PianoViewModel: ObservableObject {
    @Published var currentTime: Double = 0
    @Published var notes: [Note] = []
    var timer: Timer?
    
    func loadMidiFile(named fileName: String) throws {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mid") else {
            throw NSError(domain: "PianoViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to find MIDI file"])
        }
        
        let data = try Data(contentsOf: url)
        try parseMidiData(data)
    }
    
    private func parseMidiData(_ data: Data) throws {
        // Reset notes array
        notes = []
        
        var index = 0
        var time: Double = 0
        var activeNotes: [Int: Double] = [:]
        
        while index < data.count {
            guard index + 2 < data.count else {
                throw NSError(domain: "PianoViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unexpected end of MIDI data"])
            }
            
            let eventType = data[index] >> 4
            let channel = data[index] & 0x0F
            index += 1
            
            switch eventType {
            case 0x9:  // Note On
                let pitch = Int(data[index])
                index += 1
                let velocity = Int(data[index])
                index += 1
                if velocity > 0 {
                    activeNotes[pitch] = time
                } else {
                    if let startTime = activeNotes[pitch] {
                        notes.append(Note(pitch: pitch, startTime: startTime, duration: time - startTime))
                        activeNotes[pitch] = nil
                    }
                }
            case 0x8:  // Note Off
                let pitch = Int(data[index])
                index += 2
                if let startTime = activeNotes[pitch] {
                    notes.append(Note(pitch: pitch, startTime: startTime, duration: time - startTime))
                    activeNotes[pitch] = nil
                }
            default:
                index += 2
            }
            
            // Parse delta time (variable-length quantity)
            var deltaTime: UInt32 = 0
            var byte: UInt8
            repeat {
                guard index < data.count else {
                    throw NSError(domain: "PianoViewModel", code: 3, userInfo: [NSLocalizedDescriptionKey: "Unexpected end of MIDI data while parsing delta time"])
                }
                byte = data[index]
                deltaTime = (deltaTime << 7) | UInt32(byte & 0x7F)
                index += 1
            } while byte & 0x80 != 0
            
            time += Double(deltaTime) / 480.0  // Assuming 480 ticks per quarter note
        }
        
        if notes.isEmpty {
            throw NSError(domain: "PianoViewModel", code: 4, userInfo: [NSLocalizedDescriptionKey: "No notes found in MIDI file"])
        }
        
        print("Parsed notes: \(notes)")  // Debug print to check parsed notes
    }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.currentTime += 0.1
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        currentTime = 0
    }
    
    func isNoteActive(_ note: Note) -> Bool {
        return currentTime >= note.startTime && currentTime < note.startTime + note.duration
    }
}
