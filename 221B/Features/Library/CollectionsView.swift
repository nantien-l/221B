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
            List(books, id: \.order) { book in
                if let novel = book.novel {
                    NavigationLink(value: novel) { StoryRowView(story: novel) }
                } else if let collection = book.collection {
                    NavigationLink(value: collection) { CollectionRowView(collection: collection) }
                }
            }
            .listRowBackground(BookColors.background(for: colorScheme))
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(BookColors.background(for: colorScheme))
        }
    }
}
