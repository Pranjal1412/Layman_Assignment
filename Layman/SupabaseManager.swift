//
//  SupabaseManager.swift
//  Layman
//
//  Created by Pranjal Shinde on 31/03/26.
//

import Supabase
import Foundation

final class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private let supabaseURLString = ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? ""
    private let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_KEY"] ?? ""
    
    private init() {
        guard let url = URL(string: supabaseURLString), !supabaseKey.isEmpty else {
            fatalError("Supabase configuration missing. Check environment variables.")
        }
        
        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: supabaseKey,
            options: SupabaseClientOptions(
                auth: .init(emitLocalSessionAsInitialSession: true)
            )
        )
    }
}
