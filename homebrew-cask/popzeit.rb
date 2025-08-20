# typed: strict
# frozen_string_literal: true

cask "popzeit" do
  version "1.0.1"
  sha256 "2d8808a64d719b4551173c78d51b503ee1a72e526ff4143b00ae3c667ac5307c"

  url "https://github.com/rahulj51/popzeit/releases/download/v#{version}/PopZeit-#{version}.zip"
  name "PopZeit"
  desc "Menu bar timestamp converter"
  homepage "https://github.com/rahulj51/popzeit"

  depends_on macos: ">= :ventura"

  app "PopZeit.app"

  zap trash: [
    "~/Library/Application Support/PopZeit",
    "~/Library/Preferences/com.popzeit.PopZeit.plist",
  ]
end
