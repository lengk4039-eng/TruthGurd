package com.trustguard.insurance.controller;

import com.trustguard.insurance.dto.PackageResponse;
import com.trustguard.insurance.entity.InsuranceCategory;
import com.trustguard.insurance.service.PackageService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/packages")
@RequiredArgsConstructor
@Tag(name = "Packages")
public class PackageController {

    private final PackageService packageService;

    @GetMapping
    public List<PackageResponse> list(@RequestParam(required = false) InsuranceCategory category) {
        return packageService.list(category);
    }

    @GetMapping("/featured")
    public List<PackageResponse> featured() {
        return packageService.featured();
    }

    @GetMapping("/{id}")
    public PackageResponse getById(@PathVariable UUID id) {
        return packageService.getById(id);
    }
}
