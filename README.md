# K3s sa Cilium CNI - Automatska Instalacija

Ovaj projekat automatski instalira K3s Kubernetes klaster sa Cilium CNI umesto standardnog Flannel-a.

## Preduslovi

- Ubuntu/Debian Linux sistem
- Sudo privilegije
- Internet konekcija
- Minimum 2GB RAM
- Minimum 20GB disk prostora

## Struktura Projekta

```
mk3s/
├── mk3s_install.sh              # Glavna instalaciona skripta
├── my_k3s_cluster.config        # Konfiguracija varijabli
├── scripts/
│   ├── spremi_alate.sh          # Instalacija Kubernetes alata
│   ├── print_helper.sh          # Helper funkcije za formatiranje izlaza
│   └── kube.stuff               # Kubectl aliasi i funkcije
├── yaml/
│   ├── announce.yaml            # Cilium L2 announcement policy
│   ├── lb-ipam.yaml             # Load balancer IP pool konfiguracija
│   └── values.yaml              # Cilium Helm vrednosti
├── verify_installation.sh       # Skripta za verifikaciju instalacije
└── README.md                    # Ovaj fajl
```

## Konfiguracija

Prije pokretanja, prilagodite `my_k3s_cluster.config`:

```bash
export ARKADE_VER="0.11.17"
export INSTALL_K3S_VERSION="v1.30.3+k3s1"
export CILIUM_NAMESPACE="cilium"
export CILIUM_VERSION="1.15.6"
export CILIUM_CLUSTER_CIDR="10.42.0.0/16"
export CILIUM_LB_IP="192.168.1.240"  # Zameniti sa vašom IP adresom!
```

**VAŽNO**: Obavezno promenite `CILIUM_LB_IP` na IP adresu vašeg sistema!

## Instalacija

1. **Klonirajte ili preuzmite ovaj projekat**
2. **Prilagodite konfiguraciju** u `my_k3s_cluster.config`
3. **Pokrenite instalaciju**:
   ```bash
   chmod +x mk3s_install.sh
   ./mk3s_install.sh
   ```

## Šta Skripta Radi

### 1. K3s Instalacija
- Instalira K3s bez Traefik-a, Flannel-a i ServiceLB
- Konfigurira kubeconfig
- Dodaje KUBECONFIG u .bashrc

### 2. Alati (preko arkade)
- kubectl, helm, helmfile
- k9s, kubens, kubectx
- cilium, hubble
- jq, fzf
- I mnogi drugi...

### 3. Cilium CNI
- Instalira Cilium kao CNI
- Konfigurira Load Balancer
- Omogućava L2 announcements
- Aktivira Hubble za network observability

### 4. Kubectl Aliasi
- Dodaje korisne aliase i funkcije
- Automatski ih učitava u .bashrc

## Korisni Aliasi

Nakon instalacije imaćete pristup ovim alisima:

```bash
k           # kubectl
kgp         # kubectl get pods
kgs         # kubectl get services
kgd         # kubectl get deployments
kgn         # kubectl get nodes
kdp         # kubectl describe pod
kds         # kubectl describe service
kdd         # kubectl describe deployment
kaf         # kubectl apply -f
kdel        # kubectl delete
klog        # kubectl logs
kexec       # kubectl exec -it
kns         # kubens (switch namespace)
kctx        # kubectx (switch context)
```

### Korisne funkcije:
```bash
kgetall     # Prikaži sve resurse u svim namespace-ovima
kwatch      # Watch pods u svim namespace-ovima
kshell      # Pokreni privremenu busybox shell sesiju
```

## Verifikacija Instalacije

```bash
# Proveri status čvorova
kubectl get nodes

# Proveri Cilium status
cilium status

# Proveri sve pod-ove
kubectl get pods -A

# Pristupi K9s TUI
k9s
```

## Troubleshooting

### Cilium ne radi
```bash
# Restart Cilium pods
kubectl delete pods -n cilium -l app.kubernetes.io/name=cilium

# Proveri logove
kubectl logs -n cilium -l app.kubernetes.io/name=cilium
```

### Load Balancer problemi
- Proverite da li je `CILIUM_LB_IP` ispravno podešen
- Uverite se da je IP dostupan u vašoj mreži


### Ažuriranje Cilium
```bash
helm upgrade cilium cilium/cilium -n cilium --version <nova_verzija>
```

### Dodavanje novih nodova
```bash
# Na master nodu
sudo cat /var/lib/rancher/k3s/server/node-token

# Na worker nodu
curl -sfL https://get.k3s.io | K3S_URL=https://<master_ip>:6443 K3S_TOKEN=<token> sh -
```

## Korisni Linkovi

- [K3s Dokumentacija](https://docs.k3s.io/)
- [Cilium Dokumentacija](https://docs.cilium.io/)
- [Arkade GitHub](https://github.com/alexellis/arkade)

## Prijavljujte Probleme

Ako naidjete na probleme, proverite:
1. Log fajlove u `/var/log/`
2. Cilium status sa `cilium status`
3. Kubernetes events sa `kubectl get events -A`

---

**Napomena**: Ovaj projekat je namenjen development okruženjima. 
