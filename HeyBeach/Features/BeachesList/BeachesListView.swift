import Foundation

protocol BeachesListView: class {
  
  func showBeaches(_ list: [BeachModel])
  func showError(description: String)
  func configureForUserLoggedIn(_ loggedIn: Bool)
}
