require "shrine"

if Rails.env.development?

  require "shrine/storage/file_system"

  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/attachments/cache"), # temporary
    store: Shrine::Storage::FileSystem.new("public", prefix: "uploads/attachments/store"), # permanent
  }

else

  require "shrine/storage/memory"

  Shrine.storages = {
    cache: Shrine::Storage::Memory.new,
    store: Shrine::Storage::Memory.new,
  }

end