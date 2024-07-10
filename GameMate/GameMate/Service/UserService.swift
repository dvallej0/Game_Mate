//
//  UserService.swift
//  GameMate
//
//  Created by Daniel on 12/22/23.
//

import Foundation
import FirebaseFirestore

struct UserService {
    @MainActor
    static func fetchUser(withUid uid: String) async throws -> User {
        let snapshot = try await Firestore.firestore()
            .collection(COLLECTION_USER).document(uid).getDocument()
        return try snapshot.data(as: User.self)
    }
    
    @MainActor
    static func fetchSwipeCardUsers(user: User) async throws -> [User] {
        // Fetch all users from the Firestore collection.
        let snapshot = try await Firestore.firestore().collection("user")
            .getDocuments()

        // Convert the fetched documents to User objects.
        let users = try snapshot.documents.compactMap { try $0.data(as: User.self) }

        // Filter users based on the specified criteria.
        let filteredDocs = users.filter { potentialUser in
            // Exclude the current user, users already swiped left or right, and matches.
            guard potentialUser.id != user.id,
                  !user.swipesLeft.contains(potentialUser.id),
                  !user.swipesRight.contains(potentialUser.id),
                  !user.matches.contains(potentialUser.id) else {
                return false
            }

            // Check if the potential user's gender matches the current user's preference,
            // and vice versa, including cases where the preference is unspecified.
            let matchesGenderPreference = user.preference == GameMateGender.unspecified.rawValue ||  potentialUser.gender == user.preference
            let matchesUserPreference = potentialUser.preference == GameMateGender.unspecified.rawValue || potentialUser.preference == user.gender

            // Convert the interests arrays to sets and check for at least one shared interest.
            let userInterestsSet = Set(user.interests)
            let potentialUserInterestsSet = Set(potentialUser.interests)
            let hasSharedInterest = !userInterestsSet.intersection(potentialUserInterestsSet).isEmpty

            return matchesGenderPreference && matchesUserPreference && hasSharedInterest
        }

        // Return the filtered list of users.
        return filteredDocs
    }
    
    @MainActor
    static func onDislike(user1: User, user2: User) {
        Firestore.firestore().collection(COLLECTION_USER).document(user1.id)
            .updateData(["swipesLeft": FieldValue.arrayUnion([user2.id])])
    }
    
    @MainActor
    static func onLike(user1: User, user2: User, onMatch: () -> ()) {
        let match = user2.swipesRight.contains(user1.id)
        let u1 = Firestore.firestore().collection(COLLECTION_USER).document(user1.id)
        let u2 = Firestore.firestore().collection(COLLECTION_USER).document(user2.id)
        if !match {
            u1.updateData(["swipesRight": FieldValue.arrayUnion([user2.id])])
        } else {
            onMatch()
            u2.updateData(["swipesRight": FieldValue.arrayRemove([user1.id])])
            u1.updateData(["matches": FieldValue.arrayUnion([user2.id])])
            u2.updateData(["matches": FieldValue.arrayUnion([user1.id])])
            
            let chatKey = Firestore.firestore().collection(COLLECTION_CHAT).document().documentID
            let chatData = Chat(id: chatKey, user1: user1, user2: user2)
            guard let encodedChat = try? Firestore.Encoder().encode(chatData) else { return }
            Firestore.firestore().collection(COLLECTION_CHAT).document(chatKey).setData(encodedChat)
        }
    }
}

