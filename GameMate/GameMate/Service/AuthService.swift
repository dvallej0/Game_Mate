import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI
import Firebase
import PhotosUI

class AuthService {
    static let shared = AuthService()
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorEvent = GameMateError(content: "", display: false)
    
    @Published var signupFlowActive = false
    
    @Published var profileImage: Image?
    private var uiImage: UIImage?
    
    init() {
        Task {
            try? await fetchUser()
        }
    }
    
    @MainActor
    func register(withEmail email: String, name: String, password: String, onComplete: () -> ()) async {
        isLoading = true
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            let uid = result.user.uid
            let user = User(id: uid, email: email, name: name)
            guard let encodedUser = try? Firestore.Encoder().encode(user) else {
                isLoading = false
                return
            }
            
            try? await Firestore.firestore().collection("user").document(user.id).setData(encodedUser)
            self.currentUser = user
            signupFlowActive = true
            onComplete()
        } catch {
            print("DEBUG: Failed to register user with error \(error.localizedDescription)")
            errorEvent = GameMateError(content: error.localizedDescription)
            signout()
        }
        isLoading = false
    }
    
    func signout() {
        userSession = nil
        currentUser = nil
        try? Auth.auth().signOut()
    }
    
    @MainActor
    func login(withEmail email: String, password: String) async {
        isLoading = true
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            try? await fetchUser()
        } catch {
            print("DEBUG: Failed to login user with error \(error.localizedDescription)")
            errorEvent = GameMateError(content: error.localizedDescription)
            signout()
        }
        isLoading = false
    }
    
    @MainActor
    func fetchUser() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        currentUser = try await UserService.fetchUser(withUid: uid)
    }
    
    @MainActor
    func loadImageFromItem(item: PhotosPickerItem?) async {
        guard let item = item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        self.uiImage = uiImage
        self.profileImage = Image(uiImage: uiImage)
    }
    
    @MainActor
    func uploadUserImage() async {
        guard let currentUser = currentUser else { return }

        do {
            if let uiImage = uiImage {
                self.isLoading = true
                let imageUrl = try await ImageUploader.uploadImage(image: uiImage)
                var updatedUserData = currentUser
                updatedUserData.profileImageUrl = imageUrl // Assuming User has a profileImageUrl property

                let data = ["profileImageUrl": imageUrl ?? ""]
                try await Firestore.firestore().collection(COLLECTION_USER).document(currentUser.id).updateData(data)

                self.currentUser = updatedUserData // Update the current user in the app
            }
        } catch {
            print("DEBUG: Failed to upload image with error (error.localizedDescription)")
            errorEvent = GameMateError(content: error.localizedDescription, display: true)
        }
            self.isLoading = false
        
    }
    
    @MainActor
    func completeRegistrationFlow(age: Int, bio: String, stats: String, gender: GameMateGender, preference: GameMateGender, interests: Set<String>) async {
        guard let currentUser = currentUser else { return }
        isLoading = true
        
        do {
            let data = [
                "age": age,
                "bio": bio,
                "stats": stats,
                "gender": gender.rawValue,
                "preference": preference.rawValue,
                "interests": Array(interests)
            ] as [String: Any]
            
            try await Firestore.firestore().collection("user").document(currentUser.id).updateData(data)
            
            try? await fetchUser()
        } catch {
            print("DEBUG: Failed to set data with error \(error.localizedDescription)")
            errorEvent = GameMateError(content: error.localizedDescription)
        }
        
        isLoading = false
        signupFlowActive = false
        profileImage = nil
        uiImage = nil
    }
}
