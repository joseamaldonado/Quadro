import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ExampleView()
                .tabItem {
                    Label("Example", systemImage: "photo")
                }
            
            QuadtreeCreatorView()
                .tabItem {
                    Label("Create", systemImage: "square.on.square")
                }
        }
        .accentColor(.white)
        .preferredColorScheme(.dark)
    }
}

struct ExampleView: View {
    @State private var showingLearnMore = false
    
    var body: some View {
        VStack {
            Text("Quadtree Image Example")
                .font(.title)
                .padding()
            
            HStack {
                VStack {
                    Text("Original Image")
                        .font(.headline)
                    
                    Image("input_example")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }
                
                VStack {
                    Text("Quadtree Image")
                        .font(.headline)
                    
                    Image("output_example")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }
            }
            .padding()
            
            Text("This is an example of a quadtree image transformation. The left image shows the original input, while the right image displays the result after applying the quadtree algorithm.")
                .font(.body)
                .padding()
                .multilineTextAlignment(.center)
            
            Button(action: {
                showingLearnMore = true
            }) {
                Text("Learn More")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            .sheet(isPresented: $showingLearnMore) {
                LearnMoreView()
            }
        }
        .foregroundColor(.white)
    }
}

struct LearnMoreView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("What is a Quadtree?")
                    .font(.title)
                    .bold()
                
                Text("""
A quadtree is a tree data structure used to divide a two-dimensional space into four regions. In image processing, the quadtree algorithm works by dividing an image into smaller and smaller blocks until each block has uniform properties, such as color. This helps in compressing the image while preserving its essential features.
""")
                    .font(.body)
                
                Image("learn_more_example")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                
                Text("""
In the compression process, the image is split into smaller sections (quadrants). If a section is uniform enough (based on a threshold), it's left as is; otherwise, it's further divided. This process continues recursively until all sections are either uniform or reach a minimum size.
""")
                    .font(.body)
                
            }
            .padding()
        }
    }
}

struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct QuadtreeCreatorView: View {
    @State private var inputImage: UIImage?
    @State private var outputImage: UIImage?
    @State private var showingImagePicker = false
    @State private var isCompressing = false
    @State private var threshold: Double = 1000
    @State private var showingFullScreenImage: IdentifiableImage?
    
    var body: some View {
        VStack {
            Text("Create Quadtree Image")
                .font(.title)
                .padding()
            
            HStack {
                imageBox(image: inputImage, title: "Input Image", placeholder: "Select an image")
                imageBox(image: outputImage, title: "Output Image", placeholder: "Start transformation")
            }
            .padding()
            
            Button(action: {
                showingImagePicker = true
            }) {
                Text("Select Input Image")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Slider(value: $threshold, in: 0...2500, step: 100)
                .padding()
            Text("Threshold: \(Int(threshold))")
                .foregroundColor(.white)
            
            Button(action: {
                compressImage()
            }) {
                Text("Create Quadtree Image")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(inputImage == nil || isCompressing)
            
            if isCompressing {
                ProgressView()
                    .padding()
            }
        }
        .foregroundColor(.white)
        .sheet(isPresented: $showingImagePicker, content: {
            ImagePicker(image: $inputImage)
        })
        .fullScreenCover(item: $showingFullScreenImage) { identifiableImage in
            FullScreenImageView(image: identifiableImage.image)
        }
    }
    
    private func imageBox(image: UIImage?, title: String, placeholder: String) -> some View {
        VStack {
            Text(title)
                .font(.headline)
            
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(10)
                    .onTapGesture {
                        showingFullScreenImage = IdentifiableImage(image: image)
                    }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 300)
                    .cornerRadius(10)
                    .overlay(
                        Text(placeholder)
                            .foregroundColor(.white)
                    )
            }
        }
    }
    
    func compressImage() {
        guard let image = inputImage else { return }
        isCompressing = true
        
        // Convert image to Data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to data")
            isCompressing = false
            return
        }
        
        // Create URL request
        let url = URL(string: "http://127.0.0.1:8000/compress/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Create multipart form data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"threshold\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(Int(threshold))".data(using: .utf8)!)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // Send request
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isCompressing = false
                if let data = data, let image = UIImage(data: data) {
                    self.outputImage = image
                } else {
                    print("Failed to compress image")
                }
            }
        }.resume()
    }
}

import UniformTypeIdentifiers

struct TransferableImage: Transferable {
    let image: UIImage
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .image) { image in
            if let data = image.image.pngData() {
                return data
            } else {
                return Data()
            }
        } importing: { data in
            guard let uiImage = UIImage(data: data) else {
                throw TransferError.importFailed
            }
            return TransferableImage(image: uiImage)
        }
    }
}

enum TransferError: Error {
    case importFailed
}

struct FullScreenImageView: View {
    @Environment(\.presentationMode) var presentationMode
    let image: UIImage
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .navigationBarItems(
                        leading: Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                        },
                        trailing: ShareLink(item: TransferableImage(image: image),
                                            preview: SharePreview("Image", image: Image(uiImage: image)))
                    )
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
