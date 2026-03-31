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
    
    private init() {
        self.client = SupabaseClient(
                    supabaseURL: URL(string: "https://kbyeghoowqmccgsuyotk.supabase.co")!,
                    supabaseKey: "sb_publishable_3YkawHAzUJnhSbLBaQYaYA_cmgRGiDq",
                    options: SupabaseClientOptions(auth: .init(emitLocalSessionAsInitialSession: true)))
    }
    
}
