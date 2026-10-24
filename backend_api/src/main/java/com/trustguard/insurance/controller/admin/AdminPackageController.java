package com.trustguard.insurance.controller.admin;

import com.trustguard.insurance.dto.PackageResponse;
import com.trustguard.insurance.dto.admin.PackageRequest;
import com.trustguard.insurance.service.PackageService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/admin/packages")
@RequiredArgsConstructor
@Tag(name = "Admin · Packages")
public class AdminPackageController {

    private final PackageService packageService;

    @GetMapping
    public List<PackageResponse> list() {
        return packageService.adminList();
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public PackageResponse create(@Valid @RequestBody PackageRequest request) {
        return packageService.create(request);
    }

    @PutMapping("/{id}")
    public PackageResponse update(@PathVariable UUID id, @Valid @RequestBody PackageRequest request) {
        return packageService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable UUID id) {
        packageService.delete(id);
    }
}
