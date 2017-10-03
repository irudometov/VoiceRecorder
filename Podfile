use_frameworks!
inhibit_all_warnings!
platform :ios, '9.0'

project 'VoiceRecorder/VoiceRecorder.xcodeproj'
workspace 'VoiceRecorder.xcworkspace'

def required_pods

    pod 'AFNetworking'
    pod 'FCFileManager'
    
end

target 'VoiceRecorder' do
    required_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        puts target.name
    end
end
