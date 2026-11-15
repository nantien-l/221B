import SwiftUI

struct CollectionsView: View {
    @Environment(DataManager.self) var dataManager
    @Environment(\.colorScheme) private var colorScheme

    private var books: [(order: Int, novel: Story?, collection: Collection?)] {
        (dataManager.novels.compactMap { novel in
            novel.bookOrder.map { (order: $0, novel: Optional(novel), collection: Optional<Collection>.none) }
        } + dataManager.collections.map {
            (order: $0.bookOrder, novel: Optional<Story>.none, collection: Optional($0))
        }).sorted { $0.order < $1.order }
    }

    var body: some View {
        if let error = dataManager.loadError {
            ContentUnavailableView("Unable to Load Library", systemImage: "exclamationmark.triangle", description: Text(error))
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("THE CANONICAL LIBRARY").font(.system(.caption, design: .rounded, weight: .semibold)).tracking(1.5).foregroundStyle(colorScheme == .dark ? Color(red: 0.65, green: 0.73, blue: 0.57) : Color(red: 0.25, green: 0.37, blue: 0.28))
                        Text("The collected works").font(.system(.title, design: .serif, weight: .semibold))
                        Text("Four novels and five story collections, arranged by first book publication.").font(.subheadline).foregroundStyle(.secondary)
                    }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 290), spacing: 16)], spacing: 16) {
                        ForEach(books, id: \.order) { book in
                            if let novel = book.novel {
                                NavigationLink(value: novel) { StoryRowView(story: novel) }.buttonStyle(.plain)
                            } else if let collection = book.collection {
                                NavigationLink(value: collection) { CollectionRowView(collection: collection) }.buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24).padding(.top, 28).padding(.bottom, 72)
                .frame(maxWidth: 900)
                .frame(maxWidth: .infinity)
            }
            .background(BookColors.background(for: colorScheme).ignoresSafeArea())
        }
    }
}
