//
//  EditProfileViewModel.swift
//  GameMate
//
//  Created by Daniel on 2/8/24.
import Foundation
import PhotosUI
import SwiftUI
import Firebase

class EditProfileViewModel: ObservableObject {
    @Published var user: User
    
    @Published var selectedImage: PhotosPickerItem? {
        didSet {
            Task {
                await loadImageFromItem(item: selectedImage)
            }
        }
    }
    @Published var profileImage: Image?
    private var uiImage: UIImage?
    
    @Published var name: String
    @Published var profileImageUrl: String
    @Published var bio: String
    @Published var stats: String
    @Published var age: Int
    @Published var gender = GameMateGender.unspecified
    @Published var preference = GameMateGender.unspecified
    @Published var interests: Set<String> = []
    
    init(user: User) {
        self.user = user
        self.name = user.name
        self.bio = user.bio ?? ""
        self.stats = user.stats ?? ""
        
        self.age = user.age ?? 18
        self.gender = GameMateGender.fromString(str: user.gender)
        self.preference = GameMateGender.fromString(str: user.preference)
        self.profileImageUrl = user.profileImageUrl ?? ""
        self.interests = Set(user.interests)
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
    func updateUserData() async throws {
        var data = [String: Any]()
        
        // Check if there is an image selected for upload
        if let uiImage = uiImage {
            do {
                // Try to upload the image and get the URL
                let imageUrl = try await ImageUploader.uploadImage(image: uiImage)
                // If successful, add the image URL to the data dictionary
                data["profileImageUrl"] = imageUrl
            } catch {
                // If the upload fails, log the error and potentially handle it
                print("Failed to upload image: \(error.localizedDescription)")
                // Consider how you want to handle this error. You might want to throw it,
                // show an error message to the user, or handle it in some other way.
                // For now, let's just throw it to indicate the update operation didn't fully succeed.
                throw error
            }
        }
        
        // Continue updating other user data as before
        data["bio"] = bio
        data["stats"] = stats
        data["age"] = age
        data["gender"] = gender.rawValue
        data["preference"] = preference.rawValue
        data["interests"] = Array(interests)
        
        // Update the Firestore document with the new data
        try await Firestore.firestore().collection("user").document(user.id).updateData(data)
        
        // Refresh the current user data
        try await AuthService.shared.fetchUser()
    }
}
