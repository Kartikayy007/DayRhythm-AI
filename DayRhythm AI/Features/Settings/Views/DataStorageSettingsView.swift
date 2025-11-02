//
//  DataStorageSettingsView.swift
//  DayRhythm AI
//
//  Created by Kartikay on 01/11/25.
//

import SwiftUI
import Combine

struct DataStorageSettingsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = DataStorageViewModel()

    @AppStorage("cloudSyncEnabled") private var cloudSyncEnabled: Bool = false
    @State private var showMigrationAlert = false
    @State private var showClearDataAlert = false
    @State private var showAuthRequiredAlert = false
    @State private var migrationDirection: MigrationDirection = .toCloud

    enum MigrationDirection {
        case toCloud
        case toLocal
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Cloud Storage", systemImage: "icloud")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)

                            VStack(alignment: .leading, spacing: 12) {
                                Toggle(isOn: Binding(
                                    get: { cloudSyncEnabled },
                                    set: { newValue in
                                        if newValue && !appState.isAuthenticated {
                                            showAuthRequiredAlert = true
                                            return
                                        }

                                        if newValue != cloudSyncEnabled {
                                            migrationDirection = newValue ? .toCloud : .toLocal
                                            showMigrationAlert = true
                                        }
                                    }
                                )) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Upload Changes to Cloud")
                                                .font(.system(size: 17))
                                                .foregroundColor(.white)

                                            Text(cloudSyncEnabled ? "Your local changes sync to cloud automatically" : "View cloud tasks, but changes stay on this device only")
                                                .font(.system(size: 13))
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                    }
                                }
                                .tint(Color(hex: "FF6B35"))
                                .padding()
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        if cloudSyncEnabled {
                            VStack(alignment: .leading, spacing: 16) {
                                Label("Sync Status", systemImage: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)

                                VStack(spacing: 12) {
                                    
                                    HStack {
                                        Text("Status")
                                            .font(.system(size: 15))
                                            .foregroundColor(.white.opacity(0.7))

                                        Spacer()

                                        if viewModel.isSyncing {
                                            HStack(spacing: 4) {
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                    .scaleEffect(0.8)
                                                Text("Syncing...")
                                                    .font(.system(size: 15))
                                                    .foregroundColor(.white)
                                            }
                                        } else {
                                            HStack(spacing: 4) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.green)
                                                Text("Synced")
                                                    .font(.system(size: 15))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.08))
                                    .cornerRadius(12)

                                    
                                    HStack {
                                        Text("Last Synced")
                                            .font(.system(size: 15))
                                            .foregroundColor(.white.opacity(0.7))

                                        Spacer()

                                        Text(viewModel.lastSyncString)
                                            .font(.system(size: 15))
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.08))
                                    .cornerRadius(12)

                                    
                                    Button(action: {
                                        Task {
                                            await viewModel.syncNow()
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "arrow.clockwise")
                                                .font(.system(size: 16, weight: .semibold))
                                            Text("Sync Now")
                                                .font(.system(size: 17, weight: .semibold))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(Color.appPrimary)
                                        .cornerRadius(12)
                                    }
                                    .disabled(viewModel.isSyncing)
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Storage", systemImage: "internaldrive")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)

                            VStack(spacing: 12) {
                                
                                HStack {
                                    Text("Local Storage")
                                        .font(.system(size: 15))
                                        .foregroundColor(.white.opacity(0.7))

                                    Spacer()

                                    Text(viewModel.storageSize)
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(12)

                                
                                HStack {
                                    Text("Total Tasks")
                                        .font(.system(size: 15))
                                        .foregroundColor(.white.opacity(0.7))

                                    Spacer()

                                    Text("\(viewModel.totalEvents)")
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 16) {
                            Label("Data Management", systemImage: "exclamationmark.triangle")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.red.opacity(0.8))

                            Button(action: {
                                showClearDataAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                        .font(.system(size: 16))
                                    Text("Clear Local Data")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Data & Storage")
            .navigationBarTitleDisplayMode(.large)
            .alert("Change Sync Mode?", isPresented: $showMigrationAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Continue", role: .destructive) {
                    Task {
                        await viewModel.toggleCloudSync(migrationDirection)
                        cloudSyncEnabled = (migrationDirection == .toCloud)
                    }
                }
            } message: {
                if migrationDirection == .toCloud {
                    Text("Enable automatic upload of your local changes to the cloud. You'll still see cloud tasks even with this OFF.")
                } else {
                    Text("Disable automatic uploads. Your local changes will stay on this device only, but you'll still see cloud tasks.")
                }
            }
            .alert("Clear Local Data?", isPresented: $showClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    viewModel.clearLocalData()
                }
            } message: {
                Text("This will delete all locally stored tasks. Cloud data will not be affected if sync is enabled.")
            }
            .alert("Authentication Required", isPresented: $showAuthRequiredAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please sign in or create an account to enable cloud sync. Go to Settings > Account to sign in.")
            }
        }
        .onAppear {
            viewModel.loadStorageInfo()
        }
    }
}



class DataStorageViewModel: ObservableObject {
    @Published var isSyncing = false
    @Published var lastSyncString = "Never"
    @Published var storageSize = "0 KB"
    @Published var totalEvents = 0
    @Published var syncError: String?

    private let storageManager = StorageManager.shared
    private let cloudSyncService = CloudSyncService.shared

    func loadStorageInfo() {
        
        storageSize = storageManager.getFormattedStorageSize()

        
        let events = storageManager.loadEventsFromLocal()
        totalEvents = events.count

        
        if let lastSync = storageManager.lastSyncDate {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            lastSyncString = formatter.localizedString(for: lastSync, relativeTo: Date())
        }
    }

    func syncNow() async {
        

        await MainActor.run {
            isSyncing = true
            syncError = nil
        }

        do {
            let localEvents = storageManager.loadEventsFromLocal()
            

            let syncedEvents = try await cloudSyncService.performFullSync(localEvents: localEvents)
            

            await MainActor.run {
                totalEvents = syncedEvents.count
                storageManager.lastSyncDate = Date()
                loadStorageInfo()
                isSyncing = false
            }
        } catch {
            await MainActor.run {
                syncError = error.localizedDescription
                isSyncing = false
            }
        }
    }

    func toggleCloudSync(_ direction: DataStorageSettingsView.MigrationDirection) async {



        await MainActor.run {
            isSyncing = true
        }

        if direction == .toCloud {

            do {
                let localEvents = storageManager.loadEventsFromLocal()


                let syncedEvents = try await cloudSyncService.batchSyncEvents(
                    localEvents,
                    clearExisting: false
                )

                storageManager.saveEventsLocally(syncedEvents)
                storageManager.isCloudSyncEnabled = true

                await MainActor.run {
                    loadStorageInfo()
                    isSyncing = false

                    NotificationCenter.default.post(name: .cloudSyncDidToggle, object: nil)
                }
            } catch {
                await MainActor.run {
                    syncError = error.localizedDescription
                    isSyncing = false
                }
            }
        } else {


            storageManager.isCloudSyncEnabled = false

            await MainActor.run {
                isSyncing = false
                NotificationCenter.default.post(name: .cloudSyncDidToggle, object: nil)
            }
        }
    }

    func clearLocalData() {
        storageManager.clearLocalEvents()
        loadStorageInfo()
    }
}

#Preview {
    DataStorageSettingsView()
        .environmentObject(AppState.shared)
}
