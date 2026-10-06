import SwiftUI
import UIKit
import CoreData

struct AddEntryView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var craftType = crafts[0]
    @State private var notes = ""
    @State private var artisanName = ""
    
    // Photo
    @State private var image: UIImage?
    @State private var showingCamera = false
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section("Craft Information") {
                    
                    TextField("Title", text: $title)
                    
                    Picker("Craft", selection: $craftType) {
                        ForEach(crafts, id: \.self) { craft in
                            Text(craft)
                        }
                    }
                    
                    TextField("Artisan Name", text: $artisanName)
                    
                    TextField(
                        "Notes",
                        text: $notes,
                        axis: .vertical
                    )
                    .lineLimit(4...8)
                }
                
                Section("Photo") {
                    
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button {
                        showingCamera = true
                    } label: {
                        Label("Take Photo", systemImage: "camera")
                    }
                }
            }
            .navigationTitle("New Entry")
            .toolbar {
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView(image: $image)
            }
        }
    }
    
    private func saveEntry() {
        
        let entry = CraftEntry(context: viewContext)
        
        entry.id = UUID()
        entry.title = title
        entry.craftType = craftType
        entry.date = Date()
        entry.notes = notes
        entry.artisanName = artisanName
        
        // Save photo
        if let image = image {
            entry.photo = image.jpegData(compressionQuality: 0.7)
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Could not save: \(error)")
        }
    }
}
