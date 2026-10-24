package com.trustguard.insurance.service;

import com.trustguard.insurance.exception.BadRequestException;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

@Service
public class AvatarStorageService {

    private static final long MAX_BYTES = 5L * 1024 * 1024;
    private static final int MAX_DIMENSION = 1200;
    private static final Set<String> ALLOWED_TYPES = Set.of("image/jpeg", "image/jpg", "image/png");
    private static final String URL_PREFIX = "/uploads/avatars/";

    private final Path avatarsDir = Paths.get("uploads", "avatars").toAbsolutePath().normalize();

    public String store(UUID userId, MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BadRequestException("Choose a profile photo to upload.");
        }
        if (file.getSize() > MAX_BYTES) {
            throw new BadRequestException("Profile photos must be 5 MB or smaller.");
        }
        String contentType = file.getContentType() == null ? "" : file.getContentType().toLowerCase(Locale.ROOT);
        if (!ALLOWED_TYPES.contains(contentType)) {
            throw new BadRequestException("Upload a JPG or PNG photo.");
        }

        try {
            byte[] bytes = file.getBytes();
            BufferedImage image = ImageIO.read(new ByteArrayInputStream(bytes));
            if (image == null) {
                throw new BadRequestException("That file isn't a valid photo. Please choose another image.");
            }
            BufferedImage normalized = normalize(image);
            Files.createDirectories(avatarsDir);
            String filename = userId + "-" + UUID.randomUUID().toString().substring(0, 8) + ".jpg";
            Path target = avatarsDir.resolve(filename).normalize();
            if (!target.startsWith(avatarsDir)) {
                throw new IllegalStateException("Invalid avatar path.");
            }
            ImageIO.write(normalized, "jpg", target.toFile());
            return URL_PREFIX + filename;
        } catch (IOException ex) {
            throw new IllegalStateException("Could not store the profile photo.", ex);
        }
    }

    public void delete(String avatarUrl) {
        if (avatarUrl == null || !avatarUrl.startsWith(URL_PREFIX)) {
            return;
        }
        String filename = avatarUrl.substring(URL_PREFIX.length());
        if (filename.isEmpty() || filename.contains("/") || filename.contains("..")) {
            return;
        }
        try {
            Files.deleteIfExists(avatarsDir.resolve(filename).normalize());
        } catch (IOException ignored) {
            // A missing old photo should never block a new upload.
        }
    }

    private BufferedImage normalize(BufferedImage image) {
        int width = image.getWidth();
        int height = image.getHeight();
        double scale = Math.min(1.0, MAX_DIMENSION / (double) Math.max(width, height));
        int targetWidth = Math.max(1, (int) Math.round(width * scale));
        int targetHeight = Math.max(1, (int) Math.round(height * scale));

        BufferedImage output = new BufferedImage(targetWidth, targetHeight, BufferedImage.TYPE_INT_RGB);
        Graphics2D graphics = output.createGraphics();
        graphics.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC);
        graphics.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
        graphics.setColor(Color.WHITE);
        graphics.fillRect(0, 0, targetWidth, targetHeight);
        graphics.drawImage(image, 0, 0, targetWidth, targetHeight, null);
        graphics.dispose();
        return output;
    }
}
