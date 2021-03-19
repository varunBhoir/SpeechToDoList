//
//  ContentView.swift
//  SpeechToDoList
//
//  Created by varun bhoir on 19/03/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: ToDo.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \ToDo.created, ascending: true)], animation: .default) private var todos: FetchedResults<ToDo>
    @State private var recording = false
    @ObservedObject var micMonitor = MicMonitor(numberOfSamples: 30)
    var speechManager = SpeechManager()
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(todos, id: \.id) { item in
                        Text(item.task ?? "-")
                    }
                    .onDelete(perform:
                                deleteItems
                    )
                }
                
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.black.opacity(0.7))
                    .padding()
                    .overlay(
                        visualizerView()
                    )
                    .opacity(recording ? 1 : 0)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        recordButton()
                            .padding()
                    }
                    
                }
                
            }
            .onAppear {
                speechManager.requestAuthorization()
            }
            .navigationTitle("Speech todo list")
        }
    }
    
    func recordButton() -> some View {
        Button(action: {
            addItem()
        }) {
            Image(systemName: recording ? "stop.fill" : "mic.fill")
                .font(.system(size: 40))
                .padding()
                .cornerRadius(10)
        }
        .foregroundColor(.red)
    }
    
    func addItem() {
        if speechManager.isRecording {
            recording = false
            micMonitor.stopMonitoring()
            speechManager.stopRecording()
        } else {
            recording = true
            micMonitor.startMonitoring()
            speechManager.start { (speechText) in
                guard let text = speechText, !text.isEmpty else {
                    recording = false
                    return
                }
                DispatchQueue.main.async {
                    withAnimation {
                        let item = ToDo(context: moc)
                        item.id = UUID()
                        item.created = Date()
                        item.task = text
                        
                        do {
                            try moc.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    func normalizedSoundLevel(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 50) / 2
        return CGFloat(level * (100 / 25))
    }
    
    func visualizerView() -> some View {
        VStack {
            HStack(spacing: 4) {
                ForEach(micMonitor.soundSamples, id: \.self) { level in
                    VisualBarView(value: normalizedSoundLevel(level: level))
                }
            }
        }
    }
    
    func deleteItems(offsets: IndexSet) {
        offsets.map { todos[$0] }.forEach(moc.delete)
        do {
            try moc.save()
        } catch {
            print("Failed to save item -\(error)")
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
