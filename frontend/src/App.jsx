import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import { ToastProvider } from './components/Toast';
import { ProtectedRoute } from './router/ProtectedRoute';
import { RequireAdminRole } from './router/RequireAdminRole';
import { AppLayout } from './layouts/AppLayout';
import { FocusLayout } from './layouts/FocusLayout';
import { AdminLayout } from './layouts/AdminLayout';

import { Onboarding } from './pages/Onboarding';
import { Login } from './pages/Login';
import { Register } from './pages/Register';
import { Dashboard } from './pages/Dashboard';
import { HubEstudos } from './pages/HubEstudos';
import { Missions } from './pages/Missions';
import { Shop } from './pages/Shop';
import { MeusRecursos } from './pages/MeusRecursos';
import { Quiz } from './pages/Quiz';
import { QuizResult } from './pages/QuizResult';
import { Wallet } from './pages/Wallet';
import { Profile } from './pages/Profile';
import { Ranking } from './pages/Ranking';
import { Notifications } from './pages/Notifications';
import { ReacceptTerms } from './pages/ReacceptTerms';
import { TermsPage, PrivacyPage, RewardsPolicyPage, HowItWorksPage, CentralJuridica, LegalDocumentByRoute, MyLegalAcceptances } from './pages/Legal';
import { SupportPage } from './pages/CentralAjuda';
import { CookieBanner } from './components/CookieBanner';
import { AdminHome } from './pages/admin/AdminHome';
import { AdminWithdrawals } from './pages/admin/AdminWithdrawals';
import { AdminUsers } from './pages/admin/AdminUsers';
import { AdminAuditLogs } from './pages/admin/AdminAuditLogs';
import { AdminDailyReports } from './pages/admin/AdminDailyReports';
import { AdminShop } from './pages/admin/AdminShop';
import { AdminCategories } from './pages/admin/AdminCategories';
import { AdminQuestions } from './pages/admin/AdminQuestions';
import { AdminMissionsManage } from './pages/admin/AdminMissionsManage';
import { AdminNotifications } from './pages/admin/AdminNotifications';
import { AdminLegalDocuments } from './pages/admin/AdminLegalDocuments';
import { AdminLegalRequests } from './pages/admin/AdminLegalRequests';
import { AdminLegalAppeals } from './pages/admin/AdminLegalAppeals';

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <ToastProvider>
          <CookieBanner />
          <Routes>
            {/* Público (Seção 19.1: Onboarding -> Login/Cadastro) */}
            <Route path="/onboarding" element={<Onboarding />} />
            <Route path="/entrar" element={<Login />} />
            <Route path="/cadastro" element={<Register />} />

            {/* Legal — acessível sem autenticação (links no rodapé e no cadastro) */}
            <Route path="/legal" element={<CentralJuridica />} />
            <Route path="/legal/:type" element={<LegalDocumentByRoute />} />
            <Route path="/termos" element={<TermsPage />} />
            <Route path="/privacidade" element={<PrivacyPage />} />
            <Route path="/recompensas" element={<RewardsPolicyPage />} />
            <Route path="/como-funciona" element={<HowItWorksPage />} />
            <Route path="/suporte" element={<SupportPage />} />

            {/* Reaceite de Termos — protegido (exige login), mas sem BottomNav/Rodapé,
                pois bloqueia o resto do app até o usuário confirmar. */}
            <Route
              path="/reaceitar-termos"
              element={
                <ProtectedRoute>
                  <ReacceptTerms />
                </ProtectedRoute>
              }
            />

            {/* Protegido, com BottomNav + Rodapé (Seção 19.2, 19.3, 19.6, 19.7) */}
            <Route
              element={
                <ProtectedRoute>
                  <AppLayout />
                </ProtectedRoute>
              }
            >
              <Route path="/dashboard" element={<Dashboard />} />
              <Route path="/hub-estudos" element={<HubEstudos />} />
              <Route path="/missoes" element={<Missions />} />
              <Route path="/loja" element={<Shop />} />
              <Route path="/meus-recursos" element={<MeusRecursos />} />
              <Route path="/meus-consentimentos" element={<MyLegalAcceptances />} />
              <Route path="/carteira" element={<Wallet />} />
              <Route path="/ranking" element={<Ranking />} />
              <Route path="/notificacoes" element={<Notifications />} />
              <Route path="/perfil" element={<Profile />} />
            </Route>

            {/* Protegido, foco absoluto — sem nav/rodapé (Seção 19.4 e 19.5) */}
            <Route
              element={
                <ProtectedRoute>
                  <FocusLayout />
                </ProtectedRoute>
              }
            >
              <Route path="/quiz/:categoryId" element={<Quiz />} />
              <Route path="/quiz/:categoryId/resultado" element={<QuizResult />} />
            </Route>

            {/* Painel Administrativo — fora do Sitemap da Seção 19 (é uma ferramenta
                interna, não uma tela do produto para o usuário final). Acesso
                condicionado ao papel (admin_master / admin_financeiro / admin_suporte). */}
            <Route
              element={
                <RequireAdminRole>
                  <AdminLayout />
                </RequireAdminRole>
              }
            >
              <Route path="/admin" element={<AdminHome />} />
              <Route
                path="/admin/saques"
                element={
                  <RequireAdminRole roles={['admin_financeiro']}>
                    <AdminWithdrawals />
                  </RequireAdminRole>
                }
              />
              <Route
                path="/admin/usuarios"
                element={
                  <RequireAdminRole roles={['admin_suporte']}>
                    <AdminUsers />
                  </RequireAdminRole>
                }
              />
              <Route path="/admin/auditoria" element={<AdminAuditLogs />} />
              <Route
                path="/admin/relatorios"
                element={
                  <RequireAdminRole roles={['admin_financeiro']}>
                    <AdminDailyReports />
                  </RequireAdminRole>
                }
              />
              <Route
                path="/admin/loja"
                element={
                  <RequireAdminRole roles={['admin_financeiro']}>
                    <AdminShop />
                  </RequireAdminRole>
                }
              />
              <Route
                path="/admin/conteudo/categorias"
                element={
                  <RequireAdminRole roles={['admin_suporte']}>
                    <AdminCategories />
                  </RequireAdminRole>
                }
              />
              <Route
                path="/admin/conteudo/categorias/:categoryId/perguntas"
                element={
                  <RequireAdminRole roles={['admin_suporte']}>
                    <AdminQuestions />
                  </RequireAdminRole>
                }
              />
              <Route
                path="/admin/conteudo/missoes"
                element={
                  <RequireAdminRole roles={['admin_suporte']}>
                    <AdminMissionsManage />
                  </RequireAdminRole>
                }
              />
              <Route path="/admin/notificacoes" element={<AdminNotifications />} />
              <Route
                path="/admin/legal/documentos"
                element={
                  <RequireAdminRole roles={['admin_juridico']}>
                    <AdminLegalDocuments />
                  </RequireAdminRole>
                }
              />
              <Route
                path="/admin/legal/reclamacoes"
                element={
                  <RequireAdminRole roles={['admin_juridico']}>
                    <AdminLegalRequests />
                  </RequireAdminRole>
                }
              />
              <Route
                path="/admin/legal/recursos"
                element={
                  <RequireAdminRole roles={['admin_juridico']}>
                    <AdminLegalAppeals />
                  </RequireAdminRole>
                }
              />
            </Route>

            <Route path="/" element={<Navigate to="/onboarding" replace />} />
            <Route path="*" element={<Navigate to="/onboarding" replace />} />
          </Routes>
        </ToastProvider>
      </AuthProvider>
    </BrowserRouter>
  );
}
