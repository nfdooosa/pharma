// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ZamaEthereumConfig} from "@fhevm/solidity/config/ZamaConfig.sol";
import {euint32} from "@fhevm/solidity/lib/FHE.sol";

// pharmacy system with encrypted prescriptions
contract PharmacyCore is ZamaEthereumConfig {
    struct Prescription {
        address patient;
        address doctor;
        euint32 medicationId;
        euint32 dosage;
        uint256 prescribedAt;
        bool dispensed;
    }
    
    mapping(uint256 => Prescription) public prescriptions;
    mapping(address => uint256[]) public patientPrescriptions;
    uint256 public prescriptionCounter;
    
    event PrescriptionReceived(uint256 indexed prescriptionId, address patient);
    event MedicationDispensed(uint256 indexed prescriptionId);
    
    function receivePrescription(
        address patient,
        address doctor,
        euint32 encryptedMedicationId,
        euint32 encryptedDosage
    ) external returns (uint256 prescriptionId) {
        prescriptionId = prescriptionCounter++;
        prescriptions[prescriptionId] = Prescription({
            patient: patient,
            doctor: doctor,
            medicationId: encryptedMedicationId,
            dosage: encryptedDosage,
            prescribedAt: block.timestamp,
            dispensed: false
        });
        
        patientPrescriptions[patient].push(prescriptionId);
        emit PrescriptionReceived(prescriptionId, patient);
    }
    
    function dispenseMedication(uint256 prescriptionId) external {
        Prescription storage prescription = prescriptions[prescriptionId];
        require(!prescription.dispensed, "Already dispensed");
        
        prescription.dispensed = true;
        emit MedicationDispensed(prescriptionId);
    }
}

