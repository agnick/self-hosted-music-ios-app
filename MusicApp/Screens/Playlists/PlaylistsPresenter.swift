import UIKit

final class PlaylistsPresenter: PlaylistsPresentationLogic {
    // MARK: - Dependencies
    weak var view: PlaylistsViewController?
    
    // MARK: - Public methods
    func presentAllPlaylists() {
        DispatchQueue.main.async {
            self.view?.displayAllPlaylists()
        }
    }
    
    func presentSortOptions() {
        DispatchQueue.main.async {
            let options = [
                PlaylistsModel.SortOptions.SortOption(title: "Название (А-я)", request: .init(sortType: .titleAscending), isCancel: false),
                PlaylistsModel.SortOptions.SortOption(title: "Название (я-А)", request: .init(sortType: .titleDescending), isCancel: false),
                PlaylistsModel.SortOptions.SortOption(title: "Отменить", request: nil, isCancel: true)
            ]
            
            self.view?.displaySortOptions(PlaylistsModel.SortOptions.ViewModel(sortOptions: options))
        }
    }
    
    func presentTrackSelection(_ response: PlaylistsModel.TrackSelection.Response) {
        DispatchQueue.main.async {
            self.view?.displayTrackSelection(PlaylistsModel.TrackSelection.ViewModel(index: response.index, isSelected: response.selectedCount > 0))
        }
    }
    
    func presentEdit(_ response: PlaylistsModel.Edit.Response) {
        DispatchQueue.main.async {
            self.view?.displayEdit(PlaylistsModel.Edit.ViewModel(isEditingMode: response.isEditingMode))
        }
    }
    
    func presentError(_ response: PlaylistsModel.Error.Response) {
        DispatchQueue.main.async {
            print("Error: \(response.error.localizedDescription)")
            self.view?.displayError(PlaylistsModel.Error.ViewModel(errorDescription: response.error.localizedDescription))
        }
    }
    
    func routeTo(vc: UIViewController) {
        let backItem = UIBarButtonItem()
        backItem.title = "Плейлисты"
        view?.navigationItem.backBarButtonItem = backItem
        view?.navigationController?.pushViewController(vc, animated: true)
    }
}
