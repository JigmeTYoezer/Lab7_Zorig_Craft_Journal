import SwiftUI
import CoreData

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \CraftEntry.date,
                ascending: false
            )
        ],
        animation: .default
    )
    private var entries: FetchedResults<CraftEntry>
    
    @State private var showingAddEntry = false
    
    // Search
    @State private var searchText = ""
    
    // Sort
    @State private var sortOption = "Newest"
    
    var body: some View {
        NavigationStack {
            
            Group {
                
                // MARK: - Empty Journal
                if entries.isEmpty {
                    
                    if searchText.isEmpty {
                        
                        ContentUnavailableView(
                            "No Craft Entries",
                            systemImage: "book.closed",
                            description: Text(
                                "Tap the + button to add your first craft entry."
                            )
                        )
                        
                    } else {
                        
                        ContentUnavailableView(
                            "No Results",
                            systemImage: "magnifyingglass",
                            description: Text(
                                "No entries match \"\(searchText)\"."
                            )
                        )
                    }
                    
                } else {
                    
                    List {
                        
                        ForEach(entries) { entry in
                            
                            NavigationLink {
                                EntryDetailView(entry: entry)
                            } label: {
                                EntryRow(entry: entry)
                            }
                        }
                        .onDelete(perform: deleteEntries)
                    }
                }
            }
            .navigationTitle("Craft Journal")
            
            // MARK: - Entry Count
            .safeAreaInset(edge: .bottom) {
                Text(entryCountText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            }
            
            .toolbar {
                
                // Add button
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddEntry = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
                
                // Sort menu
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        
                        Button("Newest First") {
                            sortOption = "Newest"
                            entries.nsSortDescriptors = [
                                NSSortDescriptor(
                                    keyPath: \CraftEntry.date,
                                    ascending: false
                                )
                            ]
                        }
                        
                        Button("Oldest First") {
                            sortOption = "Oldest"
                            entries.nsSortDescriptors = [
                                NSSortDescriptor(
                                    keyPath: \CraftEntry.date,
                                    ascending: true
                                )
                            ]
                        }
                        
                        Button("A–Z") {
                            sortOption = "A-Z"
                            entries.nsSortDescriptors = [
                                NSSortDescriptor(
                                    keyPath: \CraftEntry.title,
                                    ascending: true
                                )
                            ]
                        }
                        
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
            
            // MARK: - Search
            .searchable(
                text: $searchText,
                prompt: "Search by title"
            )
            .onChange(of: searchText) { _, newValue in
                
                if newValue.isEmpty {
                    entries.nsPredicate = nil
                } else {
                    entries.nsPredicate = NSPredicate(
                        format: "title CONTAINS[cd] %@",
                        newValue
                    )
                }
            }
            
            // MARK: - Add Sheet
            .sheet(isPresented: $showingAddEntry) {
                CreateEntryView()
                    .environment(
                        \.managedObjectContext,
                        viewContext
                    )
            }
        }
    }
    
    // MARK: - Entry Count
    
    private var entryCountText: String {
        
        let count = entries.count
        
        if count == 1 {
            return "1 entry"
        } else {
            return "\(count) entries"
        }
    }
    
    // MARK: - Delete
    
    private func deleteEntries(offsets: IndexSet) {
        
        offsets.map {
            entries[$0]
        }
        .forEach(viewContext.delete)
        
        do {
            try viewContext.save()
        } catch {
            print("Could not delete: \(error)")
        }
    }
}


// MARK: - Entry Row

struct EntryRow: View {
    
    @ObservedObject var entry: CraftEntry
    
    var body: some View {
        HStack(spacing: 12) {
            
            // Photo thumbnail
            if let data = entry.photo,
               let uiImage = UIImage(data: data) {
                
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 10)
                    )
                
            } else {
                
                Image(systemName: "photo")
                    .font(.title2)
                    .frame(width: 60, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.secondary.opacity(0.1))
                    )
            }
            
            // Information
            VStack(alignment: .leading, spacing: 4) {
                
                Text(entry.title ?? "Untitled")
                    .font(.headline)
                
                Text(entry.craftType ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if let artisan = entry.artisanName,
                   !artisan.isEmpty {
                    
                    Text("Artisan: \(artisan)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}


// MARK: - Preview

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
            PersistenceController.preview.container.viewContext
        )
}
