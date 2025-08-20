# typed: strict
# frozen_string_literal: true

cask "popzeit" do
  version "1.0.1"
  sha256 "346edf003d01cbcd4d89e72c6e6ea2246f904659028235c61c6d08b612c24420"

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
