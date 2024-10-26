class ClothingUtils

  def self.generateClothedBitmap(trainer_data, direction, current_frame)
    action = trainer_data['action']

    baseBitmapFilename = getBaseOverworldSpriteFilename(action, trainer_data['skin_tone'])
    if !pbResolveBitmap(baseBitmapFilename)
      baseBitmapFilename = Settings::PLAYER_GRAPHICS_FOLDER + action
    end
    baseSprite = AnimatedBitmap.new(baseBitmapFilename)
  
    # Clone the base sprite bitmap to create the base for the player's sprite
    baseBitmap = baseSprite.bitmap.clone # nekkid sprite
    outfitFilename = getOverworldOutfitFilename(trainer_data['clothes'], action)
    outfitFilename = getOverworldOutfitFilename(Settings::PLAYER_TEMP_OUTFIT_FALLBACK) if !pbResolveBitmap(outfitFilename)
    hairFilename = getOverworldHairFilename(trainer_data['hair'])
    hatFilename = getOverworldHatFilename(trainer_data['hat'])
  
    # Use default values if color shifts are not set
    hair_color_shift = trainer_data['hair_color'] || 0
    hat_color_shift = trainer_data['hat_color'] || 0
    clothes_color_shift = trainer_data['clothes_color'] || 0
  
    # Use fallback outfit if the specified outfit cannot be resolved
    if !pbResolveBitmap(outfitFilename)
      outfitFilename = Settings::PLAYER_TEMP_OUTFIT_FALLBACK
    end
  
    # Load the outfit and hair bitmaps
    outfitBitmap = AnimatedBitmap.new(outfitFilename, clothes_color_shift)
    hairBitmapWrapper = AnimatedBitmap.new(hairFilename, hair_color_shift) if pbResolveBitmap(hairFilename)
    hatBitmapWrapper = AnimatedBitmap.new(hatFilename, hat_color_shift) if pbResolveBitmap(hatFilename)
  
    # Blit the outfit onto the base sprite
    baseBitmap.blt(0, 0, outfitBitmap.bitmap, outfitBitmap.bitmap.rect) if outfitBitmap
    current_offset = ClothingUtils.getCurrentSpriteOffset(action, direction, current_frame)
    positionHair(baseBitmap, hairBitmapWrapper.bitmap, current_offset) if hairBitmapWrapper

    if hatBitmapWrapper
      frame_count = 4 # Assuming 4 frames for hair animation; adjust as needed
      hat_frame_bitmap = ClothingUtils.duplicateHatForFrames(hatBitmapWrapper.bitmap, frame_count)
  
      frame_width = baseSprite.bitmap.width / frame_count # Calculate frame width
  
      frame_count.times do |i|
        # Calculate offset for each frame
        frame_offset = [i * frame_width, 0]
        # Adjust Y offset if frame index is odd
        frame_offset[1] -= 2 if i.odd?
        ClothingUtils.positionHat(baseBitmap, hat_frame_bitmap, frame_offset, i, frame_width)
      end
    end
    
    return baseBitmap
  end

  def self.duplicateHatForFrames(hatBitmap, frame_count)
    # Create a new bitmap for the duplicated hat frames
    frame_width = hatBitmap.width
    total_width = frame_width * frame_count
    duplicatedBitmap = Bitmap.new(total_width, hatBitmap.height)
  
    # Copy the single hat frame across each required frame
    frame_count.times do |i|
      duplicatedBitmap.blt(i * frame_width, 0, hatBitmap, hatBitmap.rect)
    end
  
    return duplicatedBitmap
  end

  def self.positionHat(baseBitmap, hatBitmap, offset, frame_index, frame_width)
    # Define a rect for each frame
    frame_rect = Rect.new(frame_index * frame_width, 0, frame_width, hatBitmap.height)
  
    # Blit only the part of the hat corresponding to the current frame
    baseBitmap.blt(offset[0], offset[1], hatBitmap, frame_rect)
  end

  def self.getCurrentSpriteOffset(action, direction, current_frame)
    case action
    when "run"
      if direction == DIRECTION_DOWN
        return Outfit_Offsets::RUN_OFFSETS_DOWN[current_frame]
      elsif direction == DIRECTION_LEFT
        return Outfit_Offsets::RUN_OFFSETS_LEFT[current_frame]
      elsif direction == DIRECTION_RIGHT
        return Outfit_Offsets::RUN_OFFSETS_RIGHT[current_frame]
      elsif direction == DIRECTION_UP
        return Outfit_Offsets::RUN_OFFSETS_UP[current_frame]
      end
    when "surf"
      #when "dive"
      if direction == DIRECTION_DOWN
        return Outfit_Offsets::SURF_OFFSETS_DOWN[current_frame]
      elsif direction == DIRECTION_LEFT
        return Outfit_Offsets::SURF_OFFSETS_LEFT[current_frame]
      elsif direction == DIRECTION_RIGHT
        return Outfit_Offsets::SURF_OFFSETS_RIGHT[current_frame]
      elsif direction == DIRECTION_UP
        return Outfit_Offsets::SURF_OFFSETS_UP[current_frame]
      end
    when "dive"
      if direction == DIRECTION_DOWN
        return Outfit_Offsets::DIVE_OFFSETS_DOWN[current_frame]
      elsif direction == DIRECTION_LEFT
        return Outfit_Offsets::DIVE_OFFSETS_LEFT[current_frame]
      elsif direction == DIRECTION_RIGHT
        return Outfit_Offsets::DIVE_OFFSETS_RIGHT[current_frame]
      elsif direction == DIRECTION_UP
        return Outfit_Offsets::DIVE_OFFSETS_UP[current_frame]
      end
    when "bike"
      if direction == DIRECTION_DOWN
        return Outfit_Offsets::BIKE_OFFSETS_DOWN[current_frame]
      elsif direction == DIRECTION_LEFT
        return Outfit_Offsets::BIKE_OFFSETS_LEFT[current_frame]
      elsif direction == DIRECTION_RIGHT
        return Outfit_Offsets::BIKE_OFFSETS_RIGHT[current_frame]
      elsif direction == DIRECTION_UP
        return Outfit_Offsets::BIKE_OFFSETS_UP[current_frame]
      end
    end
    return Outfit_Offsets::BASE_OFFSET[current_frame]
  end
end