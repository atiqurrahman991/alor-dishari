#!/bin/bash
echo "Installing Flutter..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

echo "Disabling analytics and enabling web..."
flutter config --no-analytics
flutter config --enable-web

echo "Getting dependencies..."
flutter pub get

echo "Building web project..."
flutter build web --release
