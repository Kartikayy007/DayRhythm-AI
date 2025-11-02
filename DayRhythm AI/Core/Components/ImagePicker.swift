//
//  ImagePicker.swift
//  DayRhythm AI
//
//  Image picker using PHPickerViewController - supports up to 3 images
//

import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    let maxSelectionLimit: Int
    @Environment(\.dismiss) private var dismiss

    init(selectedImages: Binding<[UIImage]>, maxSelectionLimit: Int = 3) {
        self._selectedImages = selectedImages
        self.maxSelectionLimit = min(maxSelectionLimit, 3) 
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images

        
        let remainingSlots = maxSelectionLimit - selectedImages.count
        configuration.selectionLimit = max(remainingSlots, 1)

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()

            guard !results.isEmpty else { return }

            let group = DispatchGroup()
            var loadedImages: [UIImage] = []

            for result in results {
                guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else { continue }

                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    defer { group.leave() }

                    if let error = error {
                        
                        return
                    }

                    if let uiImage = image as? UIImage {
                        loadedImages.append(uiImage)
                    }
                }
            }

            group.notify(queue: .main) {
                
                let remainingSlots = self.parent.maxSelectionLimit - self.parent.selectedImages.count
                let imagesToAdd = Array(loadedImages.prefix(remainingSlots))
                self.parent.selectedImages.append(contentsOf: imagesToAdd)
            }
        }
    }
}
