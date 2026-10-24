package com.trustguard.insurance.service;

import com.trustguard.insurance.dto.PackageResponse;
import com.trustguard.insurance.dto.admin.PackageRequest;
import com.trustguard.insurance.entity.InsuranceCategory;
import com.trustguard.insurance.entity.InsurancePackage;
import com.trustguard.insurance.exception.ResourceNotFoundException;
import com.trustguard.insurance.repository.InsurancePackageRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class PackageServiceTest {

    @Mock private InsurancePackageRepository packageRepository;

    @InjectMocks
    private PackageService packageService;

    private InsurancePackage sample() {
        return InsurancePackage.builder()
                .id(UUID.randomUUID())
                .category(InsuranceCategory.HEALTH)
                .name("Health Shield Basic")
                .tagline("tagline")
                .description("description")
                .monthlyPrice(BigDecimal.valueOf(45))
                .coverageAmount(BigDecimal.valueOf(50000))
                .durationMonths(12)
                .benefits(List.of("Outpatient care"))
                .active(true)
                .build();
    }

    @Test
    void listWithNoCategoryReturnsAllActivePackages() {
        when(packageRepository.findByActiveTrue()).thenReturn(List.of(sample()));

        assertThat(packageService.list(null)).hasSize(1);
    }

    @Test
    void listWithACategoryFiltersByIt() {
        when(packageRepository.findByActiveTrueAndCategory(InsuranceCategory.HEALTH)).thenReturn(List.of(sample()));

        List<PackageResponse> results = packageService.list(InsuranceCategory.HEALTH);

        assertThat(results).hasSize(1);
        assertThat(results.get(0).category()).isEqualTo(InsuranceCategory.HEALTH);
    }

    @Test
    void getByIdThrowsWhenNotFound() {
        UUID id = UUID.randomUUID();
        when(packageRepository.findById(id)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> packageService.getById(id)).isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void createSavesANewPackage() {
        when(packageRepository.save(any(InsurancePackage.class))).thenAnswer(inv -> {
            InsurancePackage pkg = inv.getArgument(0);
            pkg.setId(UUID.randomUUID());
            return pkg;
        });
        var request = new PackageRequest(InsuranceCategory.TRAVEL, "TravelEase", "tagline", "description",
                BigDecimal.valueOf(15), BigDecimal.valueOf(20000), 1, List.of("Trip cancellation"), false, true);

        PackageResponse response = packageService.create(request);

        assertThat(response.name()).isEqualTo("TravelEase");
        assertThat(response.category()).isEqualTo(InsuranceCategory.TRAVEL);
    }

    @Test
    void deleteSoftDeletesByFlippingActiveOff() {
        InsurancePackage pkg = sample();
        when(packageRepository.findById(pkg.getId())).thenReturn(Optional.of(pkg));
        when(packageRepository.save(any(InsurancePackage.class))).thenAnswer(inv -> inv.getArgument(0));
        ArgumentCaptor<InsurancePackage> captor = ArgumentCaptor.forClass(InsurancePackage.class);

        packageService.delete(pkg.getId());

        verify(packageRepository).save(captor.capture());
        assertThat(captor.getValue().isActive()).isFalse();
    }
}
