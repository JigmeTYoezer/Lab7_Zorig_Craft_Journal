import SwiftUI
import UIKit

struct EntryDetailView: View {
    
    @ObservedObject var entry: CraftEntry
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showingEdit = false
    
    var body: some View {
        ScrollView {
            
            VStack(alignment: .leading, spacing: 16) {
                
                // MARK: - Photo
                if let data = entry.photo,
                   let uiImage = UIImage(data: data) {
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 15)
                        )
                }
                
                // MARK: - Title
                Text(entry.title ?? "Untitled")
                    .font(.largeTitle)
                    .bold()
                
                // MARK: - Craft Type
                Text(entry.craftType ?? "")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                
                // MARK: - Artisan
                if let artisan = entry.artisanName,
                   !artisan.isEmpty {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Artisan")
                            .font(.headline)
                        
                        Text(artisan)
                            .font(.body)
                    }
                }
                
                // MARK: - Date
                if let date = entry.date {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Date")
                            .font(.headline)
                        
                        Text(date, style: .date)
                    }
                }
                
                // MARK: - Notes
                if let notes = entry.notes,
                   !notes.isEmpty {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes")
                            .font(.headline)
                        
                        Text(notes)
                            .font(.body)
                    }
                }
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding()
        }
        .navigationTitle("Craft Details")
        .navigationBarTitleDisplayMode(.inline)
        
        // MARK: - Edit Button
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showingEdit = true
                }
            }
        }
        
        // MARK: - Edit Sheet
        .sheet(isPresented: $showingEdit) {
            EditEntryView(entry: entry)
                .environment(
                    \.managedObjectContext,
                    viewContext
                )
        }
    }
}
// Minimal stub so the reference compiles. Replace with your real edit view when available.
struct EditEntryView: View {
    @ObservedObject var entry: CraftEntry
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Edit Entry") {
                    Text(entry.title ?? "Untitled")
                        .font(.headline)
                    Text("Provide an editing UI here.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

