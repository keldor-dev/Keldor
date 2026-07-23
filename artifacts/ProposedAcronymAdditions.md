# Proposed Keldor Acronym Additions

## Method

The baseline catalog was compared case-insensitively with terminology found in Keldor source, documentation, tests,
the sibling Keldor.Build.PowerShell repository, and the local documentation repository. Candidate meanings were
then checked against authoritative vendor, standards-body, open-source project, or government documentation.

Only **High** confidence records are eligible for automatic addition. **Medium** confidence records remain in the
proposal artifacts because the shorthand is common but not consistently presented as an official acronym.

## Proposals

| Acronym | Meaning | Category | Confidence | Found in | Relevance and source |
|---|---|---|---|---|---|
| ABAC | Attribute-Based Access Control | Identity and Access Management | High | External authoritative documentation | Federal identity and authorization model. [NIST SP 800-162](https://www.nist.gov/publications/guide-attribute-based-access-control-abac-definition-and-considerations-1) explicitly defines ABAC. |
| ACR | Azure Container Registry | Cloud | High | Local technical scope and external authoritative documentation | Relevant to Azure and container workflows. [Microsoft Learn](https://learn.microsoft.com/en-us/azure/aks/tutorial-kubernetes-prepare-acr) explicitly uses Azure Container Registry (ACR). |
| ADML | Administrative Template Language File | Infrastructure | High | Keldor Windows and Group Policy scope; external authoritative documentation | Relevant to Windows Group Policy administration. Microsoft's [ADMX format documentation](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/policy/admx-schema) defines associated language-resource `.adml` files. |
| ADMX | Administrative Template XML File | Infrastructure | High | Keldor Windows and Group Policy scope; external authoritative documentation | Relevant to Windows Group Policy administration. Microsoft's [Administrative Template File format](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/policy/admx-schema) defines language-neutral XML `.admx` files. |
| CRI | Container Runtime Interface | Development and DevOps | High | External authoritative documentation | Relevant to Kubernetes and container operations. The [Kubernetes documentation](https://kubernetes.io/docs/concepts/containers/cri/) explicitly defines CRI. |
| FSMO | Flexible Single Master Operations | Identity and Access Management | High | Keldor source (`Get-FSMO`) and external authoritative documentation | Directly used by a Keldor command. [Microsoft Learn](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/understand-fsmo-roles) explicitly expands FSMO. |
| GHA | GitHub Actions | Development and DevOps | Medium | Related development terminology | Relevant to CI/CD, but [GitHub Actions documentation](https://docs.github.com/en/actions) does not consistently establish `GHA` as the official abbreviation. Not added automatically. |
| GHAS | GitHub Advanced Security | Cybersecurity | High | External authoritative documentation | Relevant to source-code security and DevSecOps. [GitHub documentation](https://docs.github.com/en/code-security/reference/security-at-scale/troubleshoot-security-configurations/not-enough-ghas-licenses) explicitly uses GHAS. |
| JEA | Just Enough Administration | Identity and Access Management | High | PowerShell scope and external authoritative documentation | Relevant to least-privilege PowerShell administration. [Microsoft Learn](https://learn.microsoft.com/en-us/powershell/scripting/security/remoting/jea/overview) explicitly defines JEA. |
| M365 | Microsoft 365 | Cloud | Medium | Local and related Microsoft documentation | Highly relevant product shorthand, but Microsoft uses `M365` inconsistently as a compact label rather than a formal acronym. See the [Microsoft 365 enterprise poster](https://learn.microsoft.com/en-us/microsoft-365/enterprise/media/m365-poster/Microsoft365Enterprise.pdf). Not added automatically. |
| NTP | Network Time Protocol | Networking | High | Keldor systems-administration scope and external standard | Core enterprise time-synchronization protocol. [RFC 1305](https://www.rfc-editor.org/rfc/rfc1305.html) explicitly defines NTP. |
| NTLM | NT LAN Manager | Identity and Access Management | High | Windows and Active Directory scope; external authoritative documentation | Relevant to Windows authentication. The [Microsoft protocol specification](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-nlmp/b38c36ed-2804-4868-a9ff-8dd3182128e4) defines NT LAN Manager (NTLM). |
| NVMe | NVM Express | Infrastructure | High | Storage and infrastructure scope; external standard | Relevant to modern server storage. [NVM Express](https://nvmexpress.org/about/) explicitly defines NVM Express (NVMe). |
| OCI | Open Container Initiative | Development and DevOps | High | Container scope and external authoritative documentation | Relevant to container image and runtime standards. The [Open Container Initiative](https://opencontainers.org/faq/) defines OCI and its mission. |
| OSCAL | Open Security Controls Assessment Language | Cybersecurity | High | Federal and security-automation scope; external government documentation | Relevant to federal control automation. [NIST OSCAL](https://pages.nist.gov/OSCAL/) explicitly defines the term. |
| PSSA | PSScriptAnalyzer | Development and DevOps | Medium | Local `PSScriptAnalyzerSettings.psd1` and PowerShell tooling | Relevant to Keldor validation, but `PSSA` is community shorthand rather than a consistently official abbreviation. See the [PSScriptAnalyzer project](https://github.com/PowerShell/PSScriptAnalyzer). Not added automatically. |
| SAR | Security Assessment Report | Cybersecurity | High | Federal authorization scope; external government documentation | Relevant to federal assessment and authorization. The [FedRAMP authorization playbook](https://www.fedramp.gov/assets/resources/documents/rev4/REV_4_CSP_Authorization_Playbook_Getting_Started_with_FedRAMP.pdf) explicitly defines SAR. |
| SID | Security Identifier | Identity and Access Management | High | Keldor Active Directory code and external authoritative documentation | Directly appears in Keldor Windows administration functions. [Microsoft Learn](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-azod/ecc7dfba-77e1-4e03-ab99-114b349c7164) explicitly defines SID. |
| VHDX | Virtual Hard Disk v2 | Infrastructure | High | Hyper-V and infrastructure scope; external authoritative documentation | Relevant to Windows virtualization. The [Microsoft VHDX specification overview](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-vhdx/83f6b700-6216-40f0-aa99-9fcb421206e2) defines the Virtual Hard Disk v2 format. |
| WSMan | Web Services for Management | Infrastructure | High | PowerShell remoting scope and external authoritative documentation | Relevant to PowerShell remoting and Windows management. [Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/microsoft.wsman.management/about/about_wsman_provider) defines the WSMan provider and WS-Management. |
| ZTA | Zero Trust Architecture | Cybersecurity | High | Federal cybersecurity scope; external government documentation | Relevant to modern federal security architecture. [NIST SP 800-207](https://csrc.nist.gov/pubs/sp/800/207/final) explicitly defines ZTA. |

## Addition decision

- High confidence: **18** records; eligible for automatic addition.
- Medium confidence: **3** records; retained only in proposal artifacts.
- Low confidence: **0** records.

