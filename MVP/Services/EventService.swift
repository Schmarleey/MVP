// Services/EventService.swift
import Foundation
import Supabase

class EventService {
    static let shared = EventService()
    private var client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: Config.supabaseURL)!,
            supabaseKey: Config.supabaseApiKey
        )
    }
    
    // Lädt alle Events
    func fetchEvents(completion: @escaping (Result<[Event], Error>) -> Void) {
        Task {
            do {
                let response = try await client.from("events")
                    .select("*")
                    .order("created_at", ascending: false)
                    .execute()
                let data = response.data
                if data.isEmpty {
                    completion(.success([]))
                } else {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let events = try decoder.decode([Event].self, from: data)
                    completion(.success(events))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // Erstellt ein neues Event
    func createEvent(event: Event, completion: @escaping (Result<Event, Error>) -> Void) {
        Task {
            do {
                let response = try await client.from("events")
                    .insert(event)
                    .select("*")
                    .execute()
                let data = response.data
                if data.isEmpty {
                    let error = NSError(domain: "EventService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    completion(.failure(error))
                } else {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let newEvents = try decoder.decode([Event].self, from: data)
                    if let newEvent = newEvents.first {
                        completion(.success(newEvent))
                    } else {
                        let error = NSError(domain: "EventService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Event not created"])
                        completion(.failure(error))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}
