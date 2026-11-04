import Foundation

/// Confirms each download that finishes while the app is running, once.
@MainActor
final class BrowserDownloadNotices {
    // MARK: - Variables

    private var announcedDownloadIDs: Set<UUID>

    // MARK: - Initializers

    init(core: CrestCore) {
        announcedDownloadIDs = Set(core.state.downloads.filter(\.phase.isComplete).map(\.id))
        core.followDownloads(self) { [weak self] in self?.downloadChanged($0) }
    }

    // MARK: - Actions - Downloads

    private func downloadChanged(_ download: DownloadState) {
        guard download.phase.isComplete, announcedDownloadIDs.insert(download.id).inserted else { return }
        BrowserNoticeCenter.shared.post(.downloadFinished(download.filename))
    }
}
